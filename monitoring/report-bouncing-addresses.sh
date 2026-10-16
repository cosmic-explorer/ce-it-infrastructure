#!/bin/bash
#
# Weekly report of mailing-list addresses that have been bouncing, with the
# matching COmanage record, so an administrator can decide who has left.
#
# Why: Mailman 3.2.2 records recognised bounces (table bounceevent) but has no
# bounce scoring or automatic delivery disabling (that arrived in 3.3), and
# list memberships are provisioned from COmanage, so the right action for a
# departed member is to expire them in COmanage (roster/tools/expire-co-person.sh),
# not to remove them from a list. Hand-added subscribers are listed separately.
#
# Usage: report-bouncing-addresses.sh [--print] [--days N] [--min N]
#   --print   write the report to stdout instead of emailing it
#   --days N  look-back window in days (default 30)
#   --min N   minimum bounce events in the window to be listed (default 2)

REPORT_TO=${REPORT_TO:-"dabrown@syr.edu kjgarvey@syr.edu"}
REPORT_FROM=${REPORT_FROM:-"ce-services monitor <root@mail.cosmicexplorer.org>"}
POSTFIX_CONTAINER=${POSTFIX_CONTAINER:-mail_postfix_1}
MAILMAN_DB_CONTAINER=${MAILMAN_DB_CONTAINER:-mail_database_1}
REGISTRY_DB_CONTAINER=${REGISTRY_DB_CONTAINER:-roster_comanage-registry-database_1}
REGISTRY_URL=${REGISTRY_URL:-https://roster.cosmicexplorer.org/registry}

print_only=0; days=30; min=2
while [ $# -gt 0 ]; do
  case "$1" in
    --print) print_only=1 ;;
    --days) days=${2:-30}; shift ;;
    --min) min=${2:-2}; shift ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

work=$(mktemp -d); trap 'rm -rf "$work"' EXIT

# 1. Bounce events per address from Mailman's database.
docker exec "$MAILMAN_DB_CONTAINER" psql -U mailman -d mailmandb -At -F $'\t' -c "
  SELECT lower(email), count(*), count(DISTINCT list_id),
         string_agg(DISTINCT split_part(list_id, '.', 1), ' '),
         min(timestamp)::date, max(timestamp)::date
    FROM bounceevent
   WHERE timestamp > now() - interval '$days days'
   GROUP BY lower(email)
  HAVING count(*) >= $min
   ORDER BY count(*) DESC, lower(email);" > "$work/bounces.tsv" 2>/dev/null

total=$(grep -c . "$work/bounces.tsv")
if [ "$total" -eq 0 ]; then
  [ $print_only -eq 1 ] && echo "No addresses with $min or more bounces in the last $days days."
  exit 0
fi

# 2. Matching COmanage records (any status) for those addresses.
inlist=$(cut -f1 "$work/bounces.tsv" | sed "s/.*/'&'/" | paste -sd, -)
docker exec "$REGISTRY_DB_CONTAINER" bash -c "mysql -N -B -uregistry_user -p\"\$(cat /run/secrets/mariadb_password)\" registry -e \"
  SELECT LOWER(e.mail), p.id, p.status, CONCAT(COALESCE(n.given,''),' ',COALESCE(n.family,''))
    FROM cm_email_addresses e
    JOIN cm_co_people p ON p.id=e.co_person_id
    LEFT JOIN cm_names n ON n.co_person_id=p.id AND n.primary_name=1 AND n.deleted=0 AND n.name_id IS NULL
   WHERE e.deleted=0 AND e.email_address_id IS NULL AND p.deleted=0 AND p.co_person_id IS NULL
     AND p.co_id=2 AND LOWER(e.mail) IN ($inlist)
   GROUP BY e.mail, p.id\"" > "$work/people.tsv" 2>/dev/null

# 3. Format.
body=$(python3 - "$work/bounces.tsv" "$work/people.tsv" "$days" "$min" "$REGISTRY_URL" <<'EOF'
import sys
bounces=[l.rstrip('\n').split('\t') for l in open(sys.argv[1]) if l.strip()]
people={}
for l in open(sys.argv[2]):
    f=l.rstrip('\n').split('\t')
    if len(f)>=4: people.setdefault(f[0],[]).append(f[1:])
days,minev,url=sys.argv[3],sys.argv[4],sys.argv[5]
STATUS={'A':'Active','X':'Expired','D2':'Duplicate','PC':'Pending Confirm','PA':'Pending Approval','S':'Suspended','N':'New','D':'Deleted'}
managed=[b for b in bounces if b[0] in people]; other=[b for b in bounces if b[0] not in people]
out=[]
out.append("Mailing-list addresses with %s or more bounces in the last %s days: %d (%d with a COmanage record, %d hand-added)."%(minev,days,len(bounces),len(managed),len(other)))
out.append("")
if managed:
    out.append("COmanage members whose address is bouncing. If they have left, expire them in COmanage")
    out.append("(roster/tools/expire-co-person.sh <id> --yes); that removes them from every list and the DCC.")
    out.append("")
    out.append("  %-26s %-36s %7s %5s %-10s %-7s %s"%("Name","Email","bounces","lists","last","status","COmanage record"))
    for b in managed:
        for pid,st,name in people[b[0]]:
            out.append("  %-26.26s %-36.36s %7s %5s %-10s %-7s %s/co_people/canvas/%s"%(name.strip(),b[0],b[1],b[2],b[5],STATUS.get(st,st),url,pid))
    out.append("")
if other:
    out.append("Addresses not in COmanage (subscribed by hand). Remove in Postorius or with")
    out.append("`mailman delmembers` if they are dead:")
    out.append("")
    out.append("  %-40s %7s %5s %-10s %s"%("Email","bounces","lists","last","lists"))
    for b in other:
        out.append("  %-40.40s %7s %5s %-10s %s"%(b[0],b[1],b[2],b[5],b[3]))
    out.append("")
out.append("Source: Mailman bounceevent table (recognised bounces only); unrecognised bounces are")
out.append("forwarded to the Mailman site owner. Mailman 3.2 does not disable delivery on its own.")
print("\n".join(out))
EOF
)

if [ $print_only -eq 1 ]; then
  echo "$body"
  exit 0
fi

for to in $REPORT_TO; do
  {
    echo "From: $REPORT_FROM"
    echo "To: $to"
    echo "Subject: [ce-services] $total bouncing list address(es) in the last $days days"
    echo "Content-Type: text/plain; charset=utf-8"
    echo
    echo "$body"
  } | docker exec -i "$POSTFIX_CONTAINER" sendmail -t -f root@mail.cosmicexplorer.org
done
