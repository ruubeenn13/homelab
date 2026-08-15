# 16 — Vigilancia ampliada: SMART, heartbeats y notificaciones JSON

Cierra los huecos silenciosos que quedaban tras el doc 15: un disco que
empieza a fallar sin avisar, un cron que muere sin que nadie se entere, y
alertas que costaban de leer a las 4 de la mañana.

## Salud SMART (`scripts/smart-check.sh`)

- Cron semanal (root, domingos 4:00). Vigila NVMe (desgaste ≥90%, reserva
  ≤20%, errores de integridad media >0) y HDD (Reallocated_Sector_Ct,
  Current_Pending_Sector, Offline_Uncorrectable — cualquiera >0).
- Silencio = discos sanos; solo habla si hay síntoma real. El objetivo es
  dar semanas de margen antes de un fallo real, no ruido diario.
- Heartbeat propio a Uptime Kuma (monitor Push, intervalo 8 días): si el
  cron deja de correr, Kuma avisa aunque el script nunca llegue a ejecutarse.

## Heartbeat del dump de MySQL

- El doc 15 ya cubría el dump y su alarma si *falla*; faltaba el caso
  peligroso de que el cron *deje de correr* sin que nadie lo note.
- `mysql-dump.sh` ahora también pinga un monitor Push de Kuma al acabar
  bien (intervalo 25h = margen de un día + gracia). Silencio del cron >25h
  → Kuma avisa solo.

## Notificaciones ntfy en JSON

- Las alertas por headers HTTP solo admiten ASCII (sin tildes, sin
  emojis nativos). Se migraron al formato JSON de ntfy (POST con body
  topic/title/message/priority/tags/actions), que desbloquea: emojis y
  tildes en el título, cuerpo multilínea estructurado, y **botones de
  acción** (p. ej. la alerta de fallo del dump lleva un botón directo a
  Dozzle).
- Misma lógica y umbrales de siempre — solo cambió el mensajero.
