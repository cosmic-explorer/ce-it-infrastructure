#!/bin/bash
# Re-apply the live, non-image changes to roster_comanage-registry_1 after a
# container recreate: certificate installer cron job, PHP2Shell mitigations
# and the static front page. Run from this directory.
set -e
cd "$(dirname "$0")"
C=roster_comanage-registry_1
docker cp restart-apache ${C}:/etc/cron.daily/restart-apache
docker exec ${C} chmod +x /etc/cron.daily/restart-apache
./php2shell/apply-php2shell-mitigations.sh
./frontpage/apply-frontpage.sh
docker exec ${C} /etc/cron.daily/restart-apache
