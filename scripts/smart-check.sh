#!/usr/bin/env bash
# Chequeo SMART semanal (NVMe + HDD). Silencio = todo bien; solo habla si hay
# sintomas de fallo. Corre como root (cron de root). Heartbeat a Kuma al final.
set -uo pipefail
P=""

# --- NVMe: salud, desgaste, reserva y errores de integridad ---
NVME=$(smartctl -H -A /dev/nvme0n1)
echo "$NVME" | grep -q "PASSED" || P+="NVMe: health NO passed. "
USED=$(echo "$NVME"  | awk -F: '/Percentage Used/{gsub(/[ %]/,"",$2); print $2}')
SPARE=$(echo "$NVME" | awk -F: '/Available Spare:/{gsub(/[ %]/,"",$2); print $2}')
MEDIA=$(echo "$NVME" | awk -F: '/Media and Data Integrity Errors/{gsub(/ /,"",$2); print $2}')
[ "${USED:-0}" -ge 90 ]    && P+="NVMe: desgaste ${USED}%. "
[ "${SPARE:-100}" -le 20 ] && P+="NVMe: celdas de reserva al ${SPARE}%. "
[ "${MEDIA:-0}" -gt 0 ]    && P+="NVMe: ${MEDIA} errores de integridad. "

# --- HDD: salud + los tres contadores delatores ---
HDD=$(smartctl -H -A /dev/sda)
echo "$HDD" | grep -q "PASSED" || P+="HDD: health NO passed. "
for A in Reallocated_Sector_Ct Current_Pending_Sector Offline_Uncorrectable; do
  RAW=$(echo "$HDD" | awk -v a="$A" '$2==a {print $NF}')
  [ "${RAW:-0}" -gt 0 ] && P+="HDD: $A=$RAW. "
done

if [ -n "$P" ]; then
  docker run --rm --network proxy curlimages/curl:8.16.0 -s \
    -H "Title: SMART: disco con sintomas" -H "Priority: high" -H "Tags: rotating_light,floppy_disk" \
    -d "$P Detalle: sudo smartctl -a /dev/<disco>. Planifica copia y reemplazo con calma." \
    http://ntfy:80/homelab-alerts-03c5d07f > /dev/null
fi

. /opt/homelab/scripts/.env
docker run --rm --network proxy curlimages/curl:8.16.0 -s -o /dev/null \
  "http://uptime-kuma:3001/api/push/${SMART_PUSH_TOKEN}?status=up&msg=smart-ok" || true
