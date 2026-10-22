#!/bin/bash
#
# Apply the interim PHP2Shell mitigations (CVE-2026-109618, CVE-2026-109619)
# to the running COmanage container, which runs PHP 7.3 under mod_php and
# cannot be patched. Safe to re-run; needed again after any container
# recreate. Does a graceful Apache reload (no downtime).

set -euo pipefail
cd "$(dirname "$0")"
C=${C:-roster_comanage-registry_1}
VHOST=/etc/apache2/sites-available/000-comanage.conf

docker cp zz-php2shell-mitigation.ini "$C":/usr/local/etc/php/conf.d/zz-php2shell-mitigation.ini
docker cp php2shell.conf "$C":/etc/apache2/conf-available/php2shell.conf

# Include inside the vhost, right after the closing of <Location />, once.
if ! docker exec "$C" grep -q 'conf-available/php2shell.conf' "$VHOST"; then
  docker exec "$C" sed -i '/^<\/Location>$/{
:a; n; /^<\/Location>$/!ba
a\
# PHP2Shell interim mitigations (ce-it-infrastructure/roster/php2shell/)\
Include conf-available/php2shell.conf
}' "$VHOST"
fi
# Make sure it is not also enabled at server level (that copy is ineffective
# and confusing).
docker exec "$C" a2disconf php2shell >/dev/null 2>&1 || true

docker exec "$C" apache2ctl configtest
docker exec "$C" apache2ctl graceful

# Availability boundary for memory_limit=-1 (host has 15 GiB; the container
# normally uses about 2 GiB, 1.8 GiB of it shibd).
docker update --memory 6g --memory-swap 6g "$C" >/dev/null

echo "applied; verifying:"
docker exec "$C" grep -n 'php2shell' "$VHOST"
for u in / /registry/ /wp-login.php /bro.php; do
  printf '  %-16s ' "$u"
  curl -s -o /dev/null -w 'HTTP %{http_code}\n' --max-time 15 "https://roster.cosmicexplorer.org$u"
done
