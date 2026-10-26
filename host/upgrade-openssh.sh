#!/bin/bash
#
# Upgrade the source-built OpenSSH server on ce-services.phy.syr.edu.
#
# Background: the host is CentOS 8 (EOL), whose packaged OpenSSH 8.0 gets no
# updates, so since May 2026 sshd has been built from source into /usr/local
# and run by a systemd drop-in (ExecStart=/usr/local/sbin/sshd -D -f
# /etc/ssh/sshd_config). Security scans flag it whenever OpenSSH releases a
# new version (2026-10-24 Nessus report: 10.3 -> 10.4, CVE-2026-59995..60002).
#
# Safety: the new daemon is first started on a spare port against the live
# configuration and its banner checked before anything is installed; the
# running sshd is only restarted after `sshd -t` passes with the new binary.
# Existing SSH sessions survive a restart; keep one open while running this.
#
# Patches: files named host/patches/openssh-<version>-*.patch are applied to the
# extracted tree (upstream fixes not yet in a release; each file's header says
# where it came from). 10.4p1 needs one: its sshd_config parser only accepted
# "GssAuthentication" etc. instead of the documented GSSAPI* keywords
# (upstream bz3974, commit c147093 of 2026-07-07).
#
# Usage: upgrade-openssh.sh <version>            e.g. 10.4p1
#        VERIFY_ONLY=1 upgrade-openssh.sh <ver>   download and verify only
#        BUILD_ONLY=1  upgrade-openssh.sh <ver>   stop after the port-2222 test

set -euo pipefail
ver=${1:?usage: $0 <version, e.g. 10.4p1>}
MIRROR=${MIRROR:-https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable}
# OpenSSH release key (Damien Miller <djm@mindrot.org>), published at
# https://www.openssh.com/portable.html
RELEASE_FPR=7168B983815A5EEF59A4ADFD2A3F414E736060BA
TESTPORT=${TESTPORT:-2222}
CONFIGURE_OPTS=(--prefix=/usr/local --sysconfdir=/etc/ssh_custom --with-ssl-dir=/usr --with-pam --with-kerberos5)

dl=/root/ssh/openssh-$ver-download; src=/root/ssh/openssh-$ver
mkdir -p "$dl"; cd "$dl"
for f in openssh-$ver.tar.gz openssh-$ver.tar.gz.asc; do [ -s "$f" ] || curl -sS --max-time 300 -O "$MIRROR/$f"; done
[ -s RELEASE_KEY.asc ] || curl -sS --max-time 60 -O https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/RELEASE_KEY.asc
gpg --quiet --import RELEASE_KEY.asc 2>/dev/null || true
if ! gpg --status-fd 1 --verify openssh-$ver.tar.gz.asc openssh-$ver.tar.gz 2>/dev/null | grep -q "VALIDSIG $RELEASE_FPR"; then
  echo "signature check FAILED (expected key $RELEASE_FPR)" >&2; exit 1
fi
echo "signature OK: openssh-$ver.tar.gz signed by $RELEASE_FPR"
[ "${VERIFY_ONLY:-0}" = 1 ] && exit 0

cd /root/ssh; rm -rf "$src"; tar xzf "$dl/openssh-$ver.tar.gz"; cd "$src"
# Apply any upstream fixes we carry for this release (host/patches/openssh-<ver>-*.patch).
for p in "$(dirname "$(readlink -f "$0")")"/patches/openssh-$ver-*.patch; do
  [ -e "$p" ] || continue
  patch -p1 --forward --silent < "$p" && echo "applied $(basename "$p")"
done
./configure "${CONFIGURE_OPTS[@]}" > "$src.configure.log" 2>&1
make -j"$(nproc)" > "$src.make.log" 2>&1
echo "built: $(./sshd -V 2>&1 | head -1)"

# Prove the new daemon with the live configuration on a spare port.
./sshd -t -f /etc/ssh/sshd_config
# sshd execs the sshd-session/sshd-auth helpers from the compiled-in libexec
# path, i.e. the currently installed version's; point the test at the new ones.
"$src/sshd" -D -p "$TESTPORT" -f /etc/ssh/sshd_config -o PidFile=/run/sshd-test.pid \
  -o "SshdSessionPath=$src/sshd-session" -o "SshdAuthPath=$src/sshd-auth" &
testpid=$!
sleep 2
banner=$(timeout 10 bash -c "exec 3<>/dev/tcp/127.0.0.1/$TESTPORT; read -r -t 5 b <&3; echo \"\$b\"" 2>/dev/null || true)
kill "$testpid" 2>/dev/null || true
echo "test daemon on port $TESTPORT said: $banner"
case "$banner" in *"OpenSSH_${ver%p*}"*) ;; *) echo "unexpected banner; not installing" >&2; exit 1 ;; esac
[ "${BUILD_ONLY:-0}" = 1 ] && exit 0

# Install over /usr/local and restart the service.
make install > "$src.install.log" 2>&1
/usr/local/sbin/sshd -t -f /etc/ssh/sshd_config
systemctl restart sshd
sleep 2
systemctl is-active sshd
banner=$(timeout 10 bash -c 'exec 3<>/dev/tcp/127.0.0.1/22; read -r -t 5 b <&3; echo "$b"' 2>/dev/null || true)
echo "port 22 now says: $banner"
case "$banner" in *"OpenSSH_${ver%p*}"*) echo "upgrade complete";; *) echo "WARNING: port 22 banner unexpected; check systemctl status sshd" >&2; exit 1;; esac
