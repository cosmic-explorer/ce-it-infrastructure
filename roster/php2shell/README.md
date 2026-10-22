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

## Optional stronger step: require a Shibboleth session before PHP

`php2shell-authgate.conf.proposed` would make Apache require a Shibboleth
session for all of `/registry` before the PHP handler runs, so an
unauthenticated attacker cannot reach PHP at all; REST API calls (`*.json`) are
instead limited to this host's addresses, and static assets stay open. The
cost is that anonymous visitors go straight to the identity-provider chooser
instead of the registry landing page. Not applied; apply by appending its
contents to `php2shell.conf` and re-running the apply script.

## Indicators to watch

Apache or PHP worker processes spawning shells, `curl`/`wget`, or interpreters;
new files under `/srv/comanage-registry/app/webroot`; PHP fatal "Allowed memory
size" errors in `docker logs roster_comanage-registry_1`.
