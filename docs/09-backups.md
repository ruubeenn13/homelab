# 09 · Backups — Backrest + restic

Copia de seguridad de `/opt/homelab` (configuración, `.env` no versionados,
datos de contenedores) sobre el HDD local, con verificación de restauración real.

## Arquitectura

- **Backrest v1.14.1** en `backup.rubenlav.dev`, con autenticación propia
  (usuario+contraseña, segunda capa además de Traefik/Tailscale).
- **Repositorio `local`**: `/mnt/datos/backups` (HDD), cifrado con contraseña
  generada — **guardada en Bitwarden, pérdida = backups irrecuperables**.
- **Plan `homelab-diario`**: respalda `/opt/homelab` (excluyendo `.git`, ya
  versionado en GitHub), cron diario a las 3:00.
- **Retención**: 7 diarias · 4 semanales · 6 mensuales.
- **Verificación mensual programada**: relee el 25% del repositorio (cron,
  no solo estructura) para detectar corrupción silenciosa.

## Restauración de prueba — verificada

Snapshot `bfa3b152` restaurado a ruta separada (`/restore-test`, nunca sobre
el original) y comparado con `diff -rq` contra el original en vivo.

Resultado: **coincidencia exacta en todo lo estático** (docs, compose de
otros stacks). Las únicas diferencias fueron datos que cambian por diseño
entre el momento del snapshot y el de la comparación (bases de datos activas
de Uptime Kuma y del propio Backrest, un archivo editado tras el backup).
Ninguna indica fallo de integridad.

## Pendiente (próxima sesión)

- Segundo repositorio contra **Backblaze B2** (offsite, cierra el 3-2-1).
- Hook de ntfy en el plan para avisar si un backup falla.
