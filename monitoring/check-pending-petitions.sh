#!/bin/bash
#
# Weekly report of COmanage enrollment petitions that are waiting for an
# approver. Applications had sat unnoticed for months (one for two years)
# because nobody watches the approval queue. Emails the list to the
# administrators via the Mailman Postfix container; prints it with --print.
#
# Runs on ce-services.phy.syr.edu from /etc/cron.d/check-pending-petitions.

REPORT_TO=${REPORT_TO:-"dabrown@syr.edu kjgarvey@syr.edu"}
REPORT_FROM=${REPORT_FROM:-"ce-services monitor <root@mail.cosmicexplorer.org>"}
POSTFIX_CONTAINER=${POSTFIX_CONTAINER:-mail_postfix_1}
DB_CONTAINER=${DB_CONTAINER:-roster_comanage-registry-database_1}
REGISTRY_URL=${REGISTRY_URL:-https://roster.cosmicexplorer.org/registry}

print_only=0
[ "${1:-}" = "--print" ] && print_only=1

rows=$(docker exec "$DB_CONTAINER" bash -c 'mysql -N -uregistry_user -p"$(cat /run/secrets/mariadb_password)" registry -e "
SELECT p.id, DATE(p.created), DATEDIFF(NOW(), p.created), f.name,
       CONCAT(COALESCE(n.given,\"\"),\" \",COALESCE(n.family,\"\")), COALESCE(MIN(e.mail),\"\")
  FROM cm_co_petitions p
  LEFT JOIN cm_co_enrollment_flows f ON f.id=p.co_enrollment_flow_id
  LEFT JOIN cm_names n ON n.co_person_id=p.enrollee_co_person_id AND n.primary_name=1 AND n.deleted=0 AND n.name_id IS NULL
  LEFT JOIN cm_email_addresses e ON e.co_person_id=p.enrollee_co_person_id AND e.deleted=0 AND e.email_address_id IS NULL
 WHERE p.deleted=0 AND p.co_petition_id IS NULL AND p.status=\"PA\"
 GROUP BY p.id ORDER BY p.created;"' 2>/dev/null)

count=$(printf '%s\n' "$rows" | grep -c .)

if [ "$count" -eq 0 ]; then
  [ $print_only -eq 1 ] && echo "No petitions awaiting approval."
  exit 0
fi

body=$(
  echo "$count COmanage enrollment petition(s) are waiting for approval:"
  echo
  printf '%s\n' "$rows" | awk -F'\t' '{ printf "  %-28s %-32s applied %s (%3d days)  %s\n", $5, $6, $2, $3, $4 }'
  echo
  echo "Approve or deny each one at:"
  printf '%s\n' "$rows" | awk -F'\t' -v u="$REGISTRY_URL" '{ printf "  %s/co_petitions/view/%s\n", u, $1 }'
  echo
  echo "Approvers: PIs group for the Consortium and Observer flows; CO admins for the PI flow."
)

if [ $print_only -eq 1 ]; then
  echo "$body"
  exit 0
fi

for to in $REPORT_TO; do
  {
    echo "From: $REPORT_FROM"
    echo "To: $to"
    echo "Subject: [ce-services] $count COmanage application(s) awaiting approval"
    echo "Content-Type: text/plain; charset=utf-8"
    echo
    echo "$body"
  } | docker exec -i "$POSTFIX_CONTAINER" sendmail -t -f root@mail.cosmicexplorer.org
done
