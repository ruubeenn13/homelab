#!/usr/bin/env bash
# Dump diario de gymprofit_bot antes del backup de Backrest (3:00).
# Consistente (--single-transaction --no-tablespaces) y sin sacar credenciales del contenedor.
set -euo pipefail
DEST=/opt/homelab/stacks/mysql/dumps
F="$DEST/gymprofit_bot_$(date +%F).sql.gz"
notify_fail() {
  docker run --rm --network proxy curlimages/curl:8.16.0 -s \
    -H "Title: Dump MySQL FALLO" -H "Priority: high" -H "Tags: rotating_light" \
    -d "El volcado de gymprofit_bot ha fallado. Backrest respaldara el ultimo dump bueno." \
    http://ntfy:80/homelab-alerts-03c5d07f > /dev/null
}
trap notify_fail ERR
docker exec mysql sh -c 'MYSQL_PWD="$MYSQL_PASSWORD" mysqldump -u"$MYSQL_USER" --single-transaction --no-tablespaces --routines --triggers --events "$MYSQL_DATABASE"' | gzip > "$F"
gunzip -t "$F"
[ "$(stat -c%s "$F")" -gt 10240 ]
find "$DEST" -name "*.sql.gz" -mtime +7 -delete
