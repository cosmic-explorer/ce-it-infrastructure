#!/bin/bash
#
# Add a hidden, required "Login Identifier" enrollment attribute (type eppn,
# Login flag set, default taken from the REMOTE_USER web-server variable) to
# the self-signup enrollment flows that run without email verification.
#
# Why: COmanage 3.2 records the enrollee's authenticated identifier only in
# the collectIdentifier step, which runs after email confirmation. With
# "Email Verification Mode = None" (set 2026-08-20 on the Consortium, Project
# and Observer flows) that step never runs, so every enrollment created an
# Org Identity with no login identifier and the DCC was provisioned with an
# empty login name. This attribute captures the ePPN at the petition form
# instead, the mechanism COmanage documents for defaulting attributes from
# environment variables (the PI flow already uses it for names).
#
# The registry's REST API has no endpoint for enrollment attributes in 3.2,
# so this writes the row directly, mirroring what the "Add Enrollment
# Attribute" form stores (changelog columns included). Idempotent: flows that
# already have an i:identifier:eppn attribute are left alone.
#
# Usage: add-login-identifier-attribute.sh [--yes] [flow_id ...]
#   default flows: 10 (Project), 16 (Consortium), 19 (Observer)

set -euo pipefail
DB=${DB:-roster_comanage-registry-database_1}
ACTOR=${ACTOR:-"Claude COmanage Instance"}

confirm=""; flows=()
for a in "$@"; do
  case "$a" in
    --yes) confirm=--yes ;;
    *) flows+=("$a") ;;
  esac
done
[ ${#flows[@]} -gt 0 ] || flows=(10 16 19)
flowlist=$(IFS=,; echo "${flows[*]}")

sql() { docker exec "$DB" bash -c "mysql -uregistry_user -p\"\$(cat /run/secrets/mariadb_password)\" registry -e \"$1\""; }

echo "flows:"
sql "SELECT id, name, email_verification_mode AS verification, require_authn FROM cm_co_enrollment_flows WHERE id IN ($flowlist) AND deleted=0 AND co_enrollment_flow_id IS NULL;"
echo "existing i:identifier attributes in those flows:"
sql "SELECT id, co_enrollment_flow_id AS flow, label, attribute, required, hidden, login, default_env, ordr FROM cm_co_enrollment_attributes WHERE co_enrollment_flow_id IN ($flowlist) AND attribute LIKE 'i:identifier%' AND deleted=0 AND co_enrollment_attribute_id IS NULL;"

if [ "$confirm" != "--yes" ]; then
  echo "Dry run. Re-run with --yes to add the attribute to flows without one."
  exit 0
fi

sql "INSERT INTO cm_co_enrollment_attributes (co_enrollment_flow_id, label, description, attribute, required, required_fields, ordr, hidden, copy_to_coperson, ignore_authoritative, default_env, login, language, created, modified, co_enrollment_attribute_id, revision, deleted, actor_identifier)
SELECT f.id, 'Login Identifier', 'Your federated login identifier (ePPN), recorded automatically from the login session', 'i:identifier:eppn', 1, NULL,
       (SELECT COALESCE(MAX(a.ordr),0)+1 FROM cm_co_enrollment_attributes a WHERE a.co_enrollment_flow_id=f.id AND a.deleted=0 AND a.co_enrollment_attribute_id IS NULL),
       1, 0, 0, 'REMOTE_USER', 1, '', NOW(), NOW(), NULL, 0, 0, '$ACTOR'
  FROM cm_co_enrollment_flows f
 WHERE f.id IN ($flowlist) AND f.deleted=0 AND f.co_enrollment_flow_id IS NULL
   AND NOT EXISTS (SELECT 1 FROM cm_co_enrollment_attributes x WHERE x.co_enrollment_flow_id=f.id AND x.attribute='i:identifier:eppn' AND x.deleted=0 AND x.co_enrollment_attribute_id IS NULL);"

echo "result:"
sql "SELECT id, co_enrollment_flow_id AS flow, label, attribute, required, hidden, login, default_env, ordr, actor_identifier FROM cm_co_enrollment_attributes WHERE attribute='i:identifier:eppn' AND deleted=0 AND co_enrollment_attribute_id IS NULL ORDER BY flow;"
