#!/usr/bin/env bash
# Dump diario de gymprofit_bot antes del backup de Backrest (3:00).
# Consistente (--single-transaction), credenciales solo dentro del contenedor.
# Silencio = OK (el heartbeat delata si deja de correr); ntfy solo si falla.
set -euo pipefail
DEST=/opt/homelab/stacks/mysql/dumps
F="$DEST/gymprofit_bot_$(date +%F).sql.gz"

notify_fail() {
  BODY=$(cat << 'JSON'
{ "topic": "homelab-alerts-03c5d07f",
  "title": "💾 Dump MySQL — FALLÓ",
  "priority": 4,
  "tags": ["rotating_light"],
  "message": "El volcado nocturno de gymprofit_bot no se completó.\n\n🛟 Sin drama: Backrest respaldará el último dump bueno.\n🔎 Diagnóstico: entra por SSH y lánzalo a mano:\n/opt/homelab/scripts/mysql-dump.sh",
  "actions": [{ "action": "view", "label": "📜 Ver logs (Dozzle)", "url": "https://dozzle.rubenlav.dev" }] }
JSON
)
  docker run --rm --network proxy curlimages/curl:8.16.0 -s -o /dev/null -d "$BODY" http://ntfy:80
}
trap notify_fail ERR

docker exec mysql sh -c 'MYSQL_PWD="$MYSQL_PASSWORD" mysqldump -u"$MYSQL_USER" --single-transaction --no-tablespaces --routines --triggers --events "$MYSQL_DATABASE"' | gzip > "$F"
gunzip -t "$F"
[ "$(stat -c%s "$F")" -gt 10240 ]
find "$DEST" -name "*.sql.gz" -mtime +7 -delete

# Heartbeat a Uptime Kuma (monitor Push): si falta >25 h, alarma sola.
. /opt/homelab/scripts/.env
docker run --rm --network proxy curlimages/curl:8.16.0 -s -o /dev/null \
  "http://uptime-kuma:3001/api/push/${KUMA_PUSH_TOKEN}?status=up&msg=dump-ok" || true
