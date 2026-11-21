#!/bin/bash
#
# Upgrade nginx inside a linuxserver/letsencrypt container (mail_letsencrypt_1,
# roster_letsencrypt_1) from the stock 1.16.1 to a current release.
#
# Background: these containers publish port 80 on ce-mail/ce-roster purely to
# redirect to https; certificate renewal uses certbot in standalone mode and
# stops nginx first (see /app/le-renew.sh), so nginx is not on the renewal
# path. The image is Alpine 3.11 (EOL) and cannot be rebuilt, yet campus
# Nessus scans flag the nginx version from the Server header (2026-11-21:
# CVE-2026-123634/123007/113425, none applicable to this configuration).
#
# What it does, per container:
#   1. downloads nginx-<ver>.tar.gz + .asc from nginx.org, verifies the
#      signature against the release key pinned below, copies it in;
#   2. installs build tools from the archived Alpine 3.11 repo, builds nginx
#      with the Alpine install paths and only the static modules the live
#      config needs (ssl, http/2, realip, gzip_static, stub_status; no mail,
#      stream or third-party dynamic modules);
#   3. comments out the two lines of /config/nginx/nginx.conf that load the
#      1.16.1-only dynamic modules (none are used); the stock binary also
#      runs without them, so a container recreated from the old image still
#      starts;
#   4. tests the live config with the new binary, swaps /usr/sbin/nginx
#      (old one kept as /usr/sbin/nginx-<oldver>), restarts the s6 service,
#      checks the Server header on the published port, removes build tools;
#   5. snapshots the container as cosmicexplorer/letsencrypt:live-<date>-<stack>
#      (SNAPSHOT=0 to skip). The compose files still name
#      linuxserver/letsencrypt; a recreate must re-run this script or use
#      the snapshot image.
#
# Usage: upgrade-nginx.sh <container> <version>     e.g. mail_letsencrypt_1 1.30.7
#   BUILD_ONLY=1   download, verify, build and test only; changes nothing live
#   INSTALL_ONLY=1 skip the build (expects /tmp/nginx-build/<ver>/objs/nginx in the
#                  container from an earlier BUILD_ONLY run) and do steps 3-5

set -euo pipefail
ctr=${1:?usage: $0 <container> <nginx version>}; ver=${2:?usage: $0 <container> <nginx version>}
# Sergey Kandaurov <s.kandaurov@f5.com>, listed on https://nginx.org/en/pgp_keys.html
SIGNER_FPR=${NGINX_SIGNER_FPR:-D6786CE303D9A9022998DC6CC8464D549AF75C0A}
SIGNER_KEY=${NGINX_SIGNER_KEY:-https://nginx.org/keys/pluknet.key}
UA='Mozilla/5.0 (X11; Linux x86_64) ce-services-maintenance'
dl=/root/nginx/nginx-$ver-download
BUILD_DEPS="build-base pcre-dev zlib-dev openssl-dev linux-headers"
CONFIGURE_OPTS="--prefix=/var/lib/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules \
 --conf-path=/etc/nginx/nginx.conf --pid-path=/run/nginx/nginx.pid --lock-path=/run/nginx/nginx.lock \
 --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy \
 --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi \
 --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --user=nginx --group=nginx \
 --with-threads --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_realip_module \
 --with-http_gzip_static_module --with-http_stub_status_module"

pub=$(docker inspect -f '{{range $p,$b := .HostConfig.PortBindings}}{{range $b}}{{.HostIp}}:{{.HostPort}}{{end}}{{end}}' "$ctr")
[ -n "$pub" ] || { echo "$ctr publishes no port" >&2; exit 1; }
oldver=$(docker exec "$ctr" nginx -v 2>&1 | sed 's#.*nginx/##')
echo "$ctr: nginx $oldver on $pub -> $ver"

# 1. download and verify
mkdir -p "$dl"; cd "$dl"
for f in nginx-$ver.tar.gz nginx-$ver.tar.gz.asc; do [ -s "$f" ] || curl -fsSL -A "$UA" --max-time 300 -O "https://nginx.org/download/$f"; done
[ -s signer.key ] || curl -fsSL -A "$UA" --max-time 60 -o signer.key "$SIGNER_KEY"
gpg --quiet --import signer.key 2>/dev/null || true
gpg --status-fd 1 --verify nginx-$ver.tar.gz.asc nginx-$ver.tar.gz 2>/dev/null | grep -q "VALIDSIG $SIGNER_FPR" \
  || { echo "signature check FAILED (expected $SIGNER_FPR)" >&2; exit 1; }
echo "signature OK: nginx-$ver.tar.gz signed by $SIGNER_FPR"

if [ "${INSTALL_ONLY:-0}" != 1 ]; then
# 2. build inside the container
docker exec "$ctr" sh -c 'rm -rf /tmp/nginx-build && mkdir -p /tmp/nginx-build'
docker cp "nginx-$ver.tar.gz" "$ctr:/tmp/nginx-build/"
docker exec "$ctr" sh -c "apk add --no-cache $BUILD_DEPS >/tmp/nginx-build/apk.log 2>&1 && \
  cd /tmp/nginx-build && tar xzf nginx-$ver.tar.gz && cd nginx-$ver && \
  ./configure $CONFIGURE_OPTS >../configure.log 2>&1 && make -j\$(nproc) >../make.log 2>&1 && ./objs/nginx -v"
# Prove the new binary against a copy of the live config with the module loads removed.
docker exec "$ctr" sh -c 'sed -E "s|^([[:space:]]*)(include /etc/nginx/modules/\*\.conf;)|\1# \2|; s|^([[:space:]]*)(lua_load_resty_core off;)|\1# \2|" /config/nginx/nginx.conf > /tmp/nginx-build/nginx.conf.test'
docker exec "$ctr" sh -c "/tmp/nginx-build/nginx-$ver/objs/nginx -t -c /tmp/nginx-build/nginx.conf.test 2>&1 | tail -1"
docker exec "$ctr" sh -c "/tmp/nginx-build/nginx-$ver/objs/nginx -V 2>&1 | head -3"
[ "${BUILD_ONLY:-0}" = 1 ] && { echo "build only: nothing installed; run with INSTALL_ONLY=1 to install"; exit 0; }
fi

# 3. drop the loads of 1.16.1-only dynamic modules from the live config (idempotent)
docker exec "$ctr" sh -c 'sed -i -E "s|^([[:space:]]*)(include /etc/nginx/modules/\*\.conf;)|\1# \2  (disabled: modules built for nginx 1.16.1, none used)|; s|^([[:space:]]*)(lua_load_resty_core off;)|\1# \2|" /config/nginx/nginx.conf; grep -n -E "modules/\*\.conf|lua_load_resty_core" /config/nginx/nginx.conf'
docker exec "$ctr" nginx -t -c /config/nginx/nginx.conf 2>&1 | tail -1     # old binary still happy

# 4. test with the new binary, swap, restart, verify
docker exec "$ctr" sh -c "/tmp/nginx-build/nginx-$ver/objs/nginx -t -c /config/nginx/nginx.conf 2>&1 | tail -1 && \
  cp -p /usr/sbin/nginx /usr/sbin/nginx-$oldver && cp /tmp/nginx-build/nginx-$ver/objs/nginx /usr/sbin/nginx && \
  nginx -v && s6-svc -t /var/run/s6/services/nginx"
sleep 3
header=$(curl -sS -o /dev/null -D - --max-time 10 "http://$pub/" | tr -d '\r' | grep -i '^Server:' || true)
echo "port $pub now says: $header"
case "$header" in *"nginx/$ver"*) ;; *) echo "unexpected Server header; old binary kept at /usr/sbin/nginx-$oldver" >&2; exit 1 ;; esac
docker exec "$ctr" sh -c "apk del --no-cache $BUILD_DEPS >/dev/null 2>&1; rm -rf /tmp/nginx-build"

# 5. snapshot
if [ "${SNAPSHOT:-1}" = 1 ]; then
  tag="cosmicexplorer/letsencrypt:live-$(date +%Y%m%d)-${ctr%%_*}"
  docker commit -m "nginx $ver built from source (upgrade-nginx.sh)" "$ctr" "$tag" >/dev/null && echo "snapshot: $tag"
fi
echo "upgrade complete: $ctr nginx $oldver -> $ver"
