#!/bin/bash
#
# Attach a login identifier (default type eppn) to a COmanage Organizational
# Identity through the REST API, so that the person's federated login maps to
# their record and provisioners (DCC RemoteUser) receive their ePPN.
#
# Background: between 2026-08-19 and 2026-10-22 the self-signup flows ran with
# email verification set to "none", which skips the collectIdentifier step, so
# every enrollment in that window created an Org Identity with no login
# identifier even though the SP delivered the ePPN. The Org Identity's
# actor_identifier records the ePPN that performed the enrollment.
#
# Usage: add-login-identifier.sh <org_identity_id> <identifier> [--type eppn] [--yes]
#   without --yes: show the org identity, its current identifiers, and the
#   request that would be sent.

set -euo pipefail
REGISTRY=${REGISTRY:-https://roster.cosmicexplorer.org/registry}
CREDFILE=${CREDFILE:-/root/.comanage-api}

oi=${1:-}; ident=${2:-}; shift 2 || true
type=eppn; confirm=""
while [ $# -gt 0 ]; do
  case "$1" in
    --yes) confirm=--yes ;;
    --type) type=${2:-eppn}; shift ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done
[ -n "$oi" ] && [ -n "$ident" ] || { echo "usage: $0 <org_identity_id> <identifier> [--type eppn] [--yes]" >&2; exit 2; }
cred=$(head -n1 "$CREDFILE")

api() { curl -sS --max-time 60 -u "$cred" -X "$1" ${3:+-H 'Content-Type: application/json' --data "$3"} "$REGISTRY/$2"; }

api GET "org_identities/$oi.json" | python3 -c 'import json,sys; o=json.load(sys.stdin)["OrgIdentities"][0]; print("Org Identity %s: org=%r created=%s actor=%s" % (o["Id"], o.get("O"), o.get("Created"), o.get("ActorIdentifier")))'
echo "current identifiers:"
api GET "identifiers.json?orgidentityid=$oi" | python3 -c 'import json,sys
raw=sys.stdin.read().strip()   # COmanage answers 204 with no body when there are none
d=json.loads(raw) if raw else {}; ids=d.get("Identifiers",[])
print("  (none)" if not ids else "\n".join("  %s=%s login=%s status=%s" % (i["Type"], i["Identifier"], i.get("Login"), i.get("Status")) for i in ids))'
echo "people using this identifier as a login elsewhere:"
api GET "identifiers.json?search.identifier=$ident" 2>/dev/null | python3 -c 'import json,sys
raw=sys.stdin.read().strip()
try: d=json.loads(raw) if raw else {}; ids=[i for i in d.get("Identifiers",[]) if i.get("Login")]
except Exception: ids=[]
print("  (none)" if not ids else "\n".join("  id %s on %s %s" % (i["Id"], i["Person"]["Type"], i["Person"]["Id"]) for i in ids))'

body=$(python3 -c 'import json,sys; print(json.dumps({"RequestType":"Identifiers","Version":"1.0","Identifiers":[{"Version":"1.0","Type":sys.argv[1],"Identifier":sys.argv[2],"Login":True,"Status":"Active","Person":{"Type":"Org","Id":sys.argv[3]}}]}))' "$type" "$ident" "$oi")
echo "request: POST identifiers.json $body"

if [ "$confirm" != "--yes" ]; then
  echo "Dry run. Re-run with --yes to add it."
  exit 0
fi

code=$(curl -sS --max-time 60 -D /tmp/add-login-identifier.$$.hdr -o /tmp/add-login-identifier.$$ -w '%{http_code}' -u "$cred" -X POST -H 'Content-Type: application/json' --data "$body" "$REGISTRY/identifiers.json")
echo "HTTP $code $(head -n1 /tmp/add-login-identifier.$$.hdr | tr -d '\r')"
head -c 400 /tmp/add-login-identifier.$$; echo
rm -f /tmp/add-login-identifier.$$ /tmp/add-login-identifier.$$.hdr
[ "$code" = "201" ]
