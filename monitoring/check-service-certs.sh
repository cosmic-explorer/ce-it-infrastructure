#!/bin/bash
#
# Check the TLS certificates actually served by the Cosmic Explorer services
# and email an alert only if one is missing or has expired. Renewal itself is
# automatic (letsencrypt containers + each web container's cron.daily job), so
# approaching expiry is not alerted on. Set WARN_DAYS>0 to also warn early.
#
# Runs on ce-services.phy.syr.edu from /etc/cron.d/check-service-certs.
# Mail is sent through the Mailman Postfix container, which relays via
# smtp-relay.syr.edu, so nothing needs to be installed on the host.
#
# Usage: check-service-certs.sh [--verbose]

WARN_DAYS=${WARN_DAYS:-0}
ALERT_TO=${ALERT_TO:-dabrown@syr.edu}
ALERT_FROM=${ALERT_FROM:-"ce-services monitor <root@mail.cosmicexplorer.org>"}
POSTFIX_CONTAINER=${POSTFIX_CONTAINER:-mail_postfix_1}

# name:ip pairs to probe on port 443
SERVICES=(
  "roster.cosmicexplorer.org:128.230.146.12"
  "mail.cosmicexplorer.org:128.230.146.15"
)

verbose=0
[ "${1:-}" = "--verbose" ] && verbose=1

now=$(date +%s)
problems=()
report=()

for svc in "${SERVICES[@]}"; do
  name=${svc%%:*}
  ip=${svc##*:}
  enddate=$(echo | timeout 20 openssl s_client -servername "$name" -connect "$ip:443" 2>/dev/null \
            | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
  if [ -z "$enddate" ]; then
    problems+=("$name ($ip): could not retrieve a certificate")
    report+=("$name: NO CERTIFICATE RETRIEVED")
    continue
  fi
  end=$(date -d "$enddate" +%s)
  days=$(( (end - now) / 86400 ))
  report+=("$name: expires $enddate ($days days)")
  if [ "$end" -le "$now" ]; then
    problems+=("$name ($ip): certificate EXPIRED on $enddate")
  elif [ "$WARN_DAYS" -gt 0 ] && [ "$days" -lt "$WARN_DAYS" ]; then
    problems+=("$name ($ip): certificate expires in $days days ($enddate)")
  fi
done

if [ $verbose -eq 1 ]; then
  printf '%s\n' "${report[@]}"
fi

if [ ${#problems[@]} -eq 0 ]; then
  exit 0
fi

body=$(
  echo "The daily certificate check on $(hostname -f) found problems:"
  echo
  printf '  - %s\n' "${problems[@]}"
  echo
  echo "All services:"
  printf '  %s\n' "${report[@]}"
  echo
  echo "Renewal is automatic: the letsencrypt containers write new certificates under"
  echo "/srv/docker/{comanage,mailman}/letsencrypt/ and each web container's"
  echo "/etc/cron.daily/restart-apache installs them. Since that has not happened,"
  echo "check 'docker logs' of the letsencrypt container, then run the installer by hand:"
  echo "  docker exec mail_apache_1 /etc/cron.daily/restart-apache"
  echo "  docker exec roster_comanage-registry_1 /etc/cron.daily/restart-apache"
  echo
  echo "See ce-it-infrastructure/mail/CONTAINER-CONFIG.md."
)

{
  echo "From: $ALERT_FROM"
  echo "To: $ALERT_TO"
  echo "Subject: [ce-services] TLS certificate problem: ${problems[0]%%:*}"
  echo "Content-Type: text/plain; charset=utf-8"
  echo
  echo "$body"
} | docker exec -i "$POSTFIX_CONTAINER" sendmail -t -f root@mail.cosmicexplorer.org

printf '%s\n' "${problems[@]}" >&2
exit 1
