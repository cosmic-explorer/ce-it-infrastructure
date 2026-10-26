#!/bin/bash
#
# Restrict SSH (tcp/22) on ce-services.phy.syr.edu to the campus and VPN
# networks. Requested 2026-10-26 after the 2026-10-24 Nessus report.
#
# The host runs no firewalld/nftables service (firewalld conflicts with
# Docker's iptables management), so this keeps its own small chain, SSH-ACCESS,
# jumped to from the top of INPUT for new connections to port 22. Docker only
# touches the FORWARD/DOCKER* chains and never flushes INPUT, so the two
# coexist; the rules are re-applied at boot by ssh-firewall.service.
#
# Allowed sources (IPv4): 128.230.0.0/16 (Syracuse University campus),
# 10.57.0.0/16 (SU VPN), 127.0.0.0/8 (loopback, used by the upgrade checks).
# Everything else, and all IPv6 except ::1, is dropped after a rate-limited
# log line ("ssh-blocked:" in /var/log/messages). Established sessions are
# never affected, so applying this cannot cut the session that runs it.
#
# Usage: ssh-firewall.sh apply | status | remove

set -euo pipefail
ALLOW4=(128.230.0.0/16 10.57.0.0/16 127.0.0.0/8)
ALLOW6=(::1/128)
CHAIN=SSH-ACCESS

build() { # $1 = iptables|ip6tables, remaining = allowed sources
  local ipt=$1; shift
  $ipt -N $CHAIN 2>/dev/null || true
  $ipt -F $CHAIN
  $ipt -A $CHAIN -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
  for net in "$@"; do $ipt -A $CHAIN -s "$net" -j ACCEPT; done
  $ipt -A $CHAIN -m limit --limit 6/min --limit-burst 10 -j LOG --log-prefix "ssh-blocked: " --log-level info
  $ipt -A $CHAIN -j DROP
  # Single jump at the top of INPUT (idempotent).
  $ipt -C INPUT -p tcp --dport 22 -j $CHAIN 2>/dev/null || $ipt -I INPUT 1 -p tcp --dport 22 -j $CHAIN
}

teardown() {
  local ipt=$1
  while $ipt -D INPUT -p tcp --dport 22 -j $CHAIN 2>/dev/null; do :; done
  $ipt -F $CHAIN 2>/dev/null && $ipt -X $CHAIN 2>/dev/null || true
}

case "${1:-}" in
  apply)
    build iptables "${ALLOW4[@]}"
    build ip6tables "${ALLOW6[@]}"
    echo "ssh-firewall: port 22 restricted to ${ALLOW4[*]} (IPv6: ${ALLOW6[*]})"
    ;;
  remove)
    teardown iptables; teardown ip6tables
    echo "ssh-firewall: restrictions removed; port 22 open to all"
    ;;
  status)
    for ipt in iptables ip6tables; do
      echo "== $ipt"
      $ipt -S INPUT | grep -- "--dport 22 -j $CHAIN" || echo "(no INPUT jump: NOT active)"
      $ipt -L $CHAIN -n -v 2>/dev/null || echo "(chain $CHAIN missing)"
    done
    ;;
  *) echo "usage: $0 apply|status|remove" >&2; exit 2 ;;
esac
