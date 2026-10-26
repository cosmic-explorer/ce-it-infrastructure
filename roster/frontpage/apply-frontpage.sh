#!/bin/bash
#
# Install the static front page of roster.cosmicexplorer.org into the running
# COmanage container. The page is plain HTML served by Apache from the
# DocumentRoot, so anonymous visitors get an explanation and the sign-up links
# without any request reaching PHP (the registry itself requires a Shibboleth
# session before PHP runs; see ../php2shell/). Safe to re-run; needed after a
# container recreate. Graceful reload only.

set -euo pipefail
cd "$(dirname "$0")"
C=${C:-roster_comanage-registry_1}
BASE=/etc/apache2/apache-include-virtual-host-port443-base

docker cp index.html "$C":/var/www/html/index.html
docker exec "$C" chmod 644 /var/www/html/index.html
# Reuse the registry's favicon at the site root.
docker exec "$C" cp /srv/comanage-registry/app/webroot/favicon.ico /var/www/html/favicon.ico

# The image's vhost include redirects "/" to /registry/; the front page
# replaces that. (Idempotent: only comments the active directive.)
docker exec "$C" sed -i 's|^RedirectMatch \^/\$ /registry/$|# RedirectMatch ^/$ /registry/   (disabled: static front page at /, see ce-it-infrastructure/roster/frontpage/)|' "$BASE"

docker exec "$C" apache2ctl configtest
docker exec "$C" apache2ctl graceful

echo "applied; verifying:"
for u in / /index.html /favicon.ico /registry/ /wp-login.php; do
  printf '  %-14s ' "$u"
  curl -s -o /dev/null -w 'HTTP %{http_code} %{content_type} %{redirect_url}\n' --max-time 15 "https://roster.cosmicexplorer.org$u"
done
