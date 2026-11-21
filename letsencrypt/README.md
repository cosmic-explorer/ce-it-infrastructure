# Let's Encrypt helper containers (mail_letsencrypt_1, roster_letsencrypt_1)

Both stacks run `linuxserver/letsencrypt` (image from 2020, Alpine 3.11, no
longer rebuildable) to obtain the host certificates; the compose files are
`mail/letsencrypt.yml` and `roster/letsencrypt.yml`. Each container publishes
only port 80 on its stack's address and its nginx does nothing but redirect
to https. Renewal is certbot in *standalone* mode: `/app/le-renew.sh` (cron,
02:08 daily) stops nginx, lets certbot bind port 80, then starts nginx again,
so nginx is not part of the renewal path. The stacks' Apache containers pick
the renewed certificate up via their own cron scripts (see `mail/README.md`).

## upgrade-nginx.sh

Campus Nessus scans report the nginx version from the `Server:` header
(2026-11-21: 1.16.1, CVE-2026-123634/123007/113425; none applies to a
redirect-only server without HTTP/2 on port 80, mail proxy or SSI/mirror, but
the finding stays open until the version changes). The script rebuilds nginx
from the signed nginx.org tarball inside the container with Alpine's install
paths and only the static modules the live config needs, comments out the
two lines in `/config/nginx/nginx.conf` that load third-party dynamic modules
built for 1.16.1 (none are used; the stock binary runs without them too),
swaps `/usr/sbin/nginx` (old binary kept as `/usr/sbin/nginx-1.16.1`),
restarts the s6 service, checks the header and snapshots the container.

```sh
# safe part: download, verify signature, build, test against the live config
BUILD_ONLY=1   /root/ce-it-infrastructure/letsencrypt/upgrade-nginx.sh mail_letsencrypt_1 1.30.7
# live part: config edit, binary swap, restart, header check, snapshot
INSTALL_ONLY=1 /root/ce-it-infrastructure/letsencrypt/upgrade-nginx.sh mail_letsencrypt_1 1.30.7
# or both in one go
/root/ce-it-infrastructure/letsencrypt/upgrade-nginx.sh roster_letsencrypt_1 1.30.7
```

The compose files still name `linuxserver/letsencrypt`; a recreated container
comes back with nginx 1.16.1 until the script is run again (or the compose
`image:` is pointed at the `cosmicexplorer/letsencrypt:live-<date>-<mail|roster>` snapshot).
Build logs stay in `/tmp/nginx-build/` inside the container until the install
step removes them; the verified tarball is kept in `/root/nginx/`.
