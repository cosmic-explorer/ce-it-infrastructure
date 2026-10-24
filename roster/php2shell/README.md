# PHP2Shell (CVE-2026-109618, CVE-2026-109619) and the COmanage container

The COmanage registry container runs PHP 7.3.17 under Apache mod_php (prefork).
PHP's 2026-10-21 security release fixes the two "PHP2Shell" bugs in 8.2+ only,
with minimal backports for 7.4, 8.0 and 8.1; there is no fix for 7.3, and the
PHP team rates mod_php the highest-risk SAPI because an unauthenticated
request can trigger the out-of-memory path before application code runs. The
only complete fix is a newer PHP, which for us means COmanage 4.x on a
rebuilt image. Until then this directory holds the advisory's interim
mitigations, applied to the running container by
`apply-php2shell-mitigations.sh` (re-run after any container recreate):

| File | Destination | Effect |
|------|-------------|--------|
| `zz-php2shell-mitigation.ini` | `/usr/local/etc/php/conf.d/` | `session.upload_progress.enabled=0` (blocks the confirmed CVE-2026-109619 path), small request limits, `expose_php`/`display_errors` off |
| `php2shell.conf` | `/etc/apache2/conf-available/`, Included inside the 443 vhost after `<Location />` | `php_admin_value memory_limit -1` (removes PHP's attacker-reachable memory-limit failure, per the advisory) and `Require all denied` for every URL outside `/registry` and `/Shibboleth.sso`, so bot probes for `*.php` never reach mod_php |
| (docker) | `docker update --memory 6g --memory-swap 6g` | cgroup boundary that replaces the PHP memory limit; the container normally uses ~2 GiB |

Applied 2026-10-22. Verified: `/wp-login.php` and `/bro.php` return 403 from
Apache; `/registry/` and the REST API behave as before; `X-Powered-By` gone.

The Let's Encrypt containers also carry PHP 7.3 (php-fpm behind nginx, never
reachable from outside because nginx redirects everything on port 80). Their
php-fpm is stopped at container start by
`/srv/docker/{comanage,mailman}/letsencrypt/config/custom-cont-init.d/10-disable-php-fpm`.
The Mailman web stack contains no PHP.

## Login gate (enabled 2026-10-24)

On ITS advice, `php2shell.conf` now also requires a Shibboleth session for
everything under `/registry` before the PHP handler runs, so unauthenticated
traffic never reaches mod_php. Anonymous visitors go straight to the
identity-provider chooser instead of the registry Home page. Exceptions:
static assets (`css`, `js`, `img`, `files`, `local-resources`, `favicon.ico`)
are open, and REST API calls (`*.json`, HTTP Basic) are allowed only from this
host and the container networks (192.168.100.1, 172.30.100.0/24,
128.230.146.17).

Two Apache details matter here. CakePHP's `.htaccess` rewrites every URL to
`/registry/index.php` and Apache re-evaluates Location blocks on the rewritten
URI, so the exceptions are written as `<If>`/`<ElseIf>` tests on
`%{THE_REQUEST}` (the original request line) inside `<Location /registry>`,
not as separate LocationMatch blocks. And mod_shib enforces
`ShibRequestSetting requireSession` before `Require` is evaluated, so each
exception also sets `requireSession 0`.

Verified after enabling: `/registry/` and the sign-up start URL redirect to
the discovery service; CSS and favicon return 200; anonymous `*.json` returns
401 and API-user calls 200 from this host; the logout rewrite still works;
`/wp-login.php` still 403. Rollback: remove the Location block from
`php2shell.conf` and re-run the apply script.

## Indicators to watch

Apache or PHP worker processes spawning shells, `curl`/`wget`, or interpreters;
new files under `/srv/comanage-registry/app/webroot`; PHP fatal "Allowed memory
size" errors in `docker logs roster_comanage-registry_1`.
