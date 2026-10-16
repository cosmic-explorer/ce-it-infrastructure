#!/bin/bash
#
# Expire a COmanage CO Person through the REST API by expiring each of their
# CO Person Roles. COmanage then recalculates the person's status to Expired
# and runs every active provisioner: Mailman unsubscribes them from all lists,
# the DCC author is set inactive, GitHub team memberships are removed. The
# change goes through the same model code as the web interface, so the
# changelog, history records and provisioning trail are identical; the actor
# recorded is the API user.
#
# Usage: expire-co-person.sh <co_person_id>                  show the person and roles
#        expire-co-person.sh <co_person_id> --yes [--cou ID]  expire the roles
#
# The REST API refuses to edit a role that has no COU once the CO has COUs
# ("403 COU Does Not Exist"); roles created before the COUs existed are like
# that. Pass --cou <id> (see cous.json?coid=2) to place such roles in a COU as
# part of expiring them; roles that already have a COU keep theirs.
#
# Credentials: /root/.comanage-api holding "username:password" for an API user
# (Platform > API Users). API users have full registry privileges in 3.2.

set -euo pipefail

REGISTRY=${REGISTRY:-https://roster.cosmicexplorer.org/registry}
CREDFILE=${CREDFILE:-/root/.comanage-api}

id=${1:-}; shift || true
confirm=""; cou=""
while [ $# -gt 0 ]; do
  case "$1" in
    --yes) confirm=--yes ;;
    --cou) cou=${2:-}; shift ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done
[ -n "$id" ] || { echo "usage: $0 <co_person_id> [--yes] [--cou ID]" >&2; exit 2; }
cred=$(head -n1 "$CREDFILE")

api() { # method path [json-body]
  if [ $# -ge 3 ]; then
    curl -sS --max-time 60 -u "$cred" -X "$1" -H 'Content-Type: application/json' --data "$3" "$REGISTRY/$2"
  else
    curl -sS --max-time 60 -u "$cred" -X "$1" "$REGISTRY/$2"
  fi
}

person=$(api GET "co_people/$id.json")
names=$(api GET "names.json?copersonid=$id")
roles=$(api GET "co_person_roles.json?copersonid=$id")

python3 - "$person" "$names" "$roles" <<'EOF'
import json, sys
p = json.loads(sys.argv[1])["CoPeople"][0]
n = [x for x in json.loads(sys.argv[2]).get("Names", []) if x.get("PrimaryName")]
r = json.loads(sys.argv[3]).get("CoPersonRoles", [])
print("CO Person %s: %s %s  status=%s" % (p["Id"], n[0]["Given"] if n else "?", n[0]["Family"] if n else "?", p["Status"]))
for x in r:
    print("  role %s: status=%s affiliation=%s cou=%s org=%s" % (x["Id"], x["Status"], x.get("Affiliation"), x.get("CouId"), x.get("O")))
EOF

if [ "$confirm" != "--yes" ]; then
  echo "Dry run. Re-run with --yes to expire every active role above."
  exit 0
fi

# Build and send one PUT per non-expired role, carrying over the writable fields.
python3 - "$roles" "$cou" <<'EOF' | while IFS=$'\t' read -r rid body; do
import json, sys
# The API represents the person as Person:{Type:"CO",Id:...}, not CoPersonId.
keep = ("Person","CouId","Affiliation","Title","O","Ou","ValidFrom","ValidThrough","SponsorCoPersonId")
default_cou = sys.argv[2]
for x in json.loads(sys.argv[1]).get("CoPersonRoles", []):
    if x["Status"] in ("Expired", "Deleted"):
        continue
    rec = {"Version": "1.0", "Status": "Expired"}
    rec.update({k: x[k] for k in keep if x.get(k) not in (None, "")})
    if not rec.get("CouId") and default_cou:
        rec["CouId"] = default_cou
    print(x["Id"] + "\t" + json.dumps({"RequestType": "CoPersonRoles", "Version": "1.0", "CoPersonRoles": [rec]}))
EOF
  printf 'PUT co_person_roles/%s ... ' "$rid"
  code=$(curl -sS --max-time 60 -D /tmp/expire-co-person.$$.hdr -o /tmp/expire-co-person.$$ -w '%{http_code}' -u "$cred" -X PUT -H 'Content-Type: application/json' --data "$body" "$REGISTRY/co_person_roles/$rid.json")
  echo "HTTP $code"
  if [ "$code" != "200" ]; then
    # COmanage puts the reason in the HTTP status line and often sends no body
    echo "  status line: $(head -n1 /tmp/expire-co-person.$$.hdr | tr -d '\r')"
    echo "  body: $(head -c 400 /tmp/expire-co-person.$$)"
  fi
  rm -f /tmp/expire-co-person.$$ /tmp/expire-co-person.$$.hdr
done

sleep 3
api GET "co_people/$id.json" | python3 -c 'import json,sys; print("Person status now:", json.load(sys.stdin)["CoPeople"][0]["Status"])'
