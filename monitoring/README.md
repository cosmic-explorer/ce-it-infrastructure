# Host-level monitoring for ce-services

The services have no health checks or alerting of their own; the Mailman web
server served an expired certificate for eighteen months (April 2025 to
October 2026) before anyone noticed. This directory holds the small checks
that run from the host's cron to catch that class of problem.

## check-service-certs

`check-service-certs.sh` connects to port 443 on both service IPs, reads the
certificate each one actually serves, and emails an alert only if a certificate
is missing or has expired. Renewal is automatic (the letsencrypt containers
obtain new certificates and each web container's `cron.daily/restart-apache`
installs them), so approaching expiry is deliberately not alerted on; set
`WARN_DAYS` in the cron file if you want early warnings. Mail goes out through the
`mail_postfix_1` container (which relays via `smtp-relay.syr.edu`), so the host
needs no MTA.

Install or update with:

```sh
install -m 755 check-service-certs.sh /usr/local/sbin/check-service-certs.sh
install -m 644 check-service-certs.cron /etc/cron.d/check-service-certs
```

Run by hand with `check-service-certs.sh --verbose`. It exits 0 when all is
well and 1 (after sending mail) otherwise. Output is appended to
`/var/log/check-service-certs.log`.

## check-pending-petitions

`check-pending-petitions.sh` lists COmanage enrollment petitions in status
"Pending Approval" (name, email, date applied, days waiting, flow, link) and
emails them to the administrators once a week. On 2026-10-14 seven
applications were found waiting, one of them for over a year, because nobody
watches the approval queue. `--print` writes the report to stdout instead of
sending it.

Install with:

```sh
install -m 755 check-pending-petitions.sh /usr/local/sbin/check-pending-petitions.sh
install -m 644 check-pending-petitions.cron /etc/cron.d/check-pending-petitions
```
