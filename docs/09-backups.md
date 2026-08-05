# 09 · Backups — Backrest + restic (3-2-1 completo)

Copia de seguridad de `/opt/homelab` en dos repositorios: HDD local y
Backblaze B2 (offsite). Restauración verificada en ambos.

## Arquitectura

- **Backrest v1.14.1** en `backup.rubenlav.dev`, con autenticación propia.
- **Repo `local`**: `/mnt/datos/backups` (HDD). Contraseña en Bitwarden.
- **Repo `b2`**: Backblaze B2, bucket `rubenlav-homelab-b2`, región EU
  (`s3.eu-central-003.backblazeb2.com`), conectado por **API S3**
  (`s3:https://...`). Application key restringida al bucket (Read & Write,
  sin listado global), credenciales como env vars en la config de Backrest
  (fuera de Git). Contraseña restic **propia y distinta** de la local,
  en Bitwarden — pérdida = backup offsite irrecuperable.
- **Bucket**: privado; Object Lock y cifrado del bucket desactivados
  (restic ya cifra en cliente); ciclo de vida en **"Keep only the last
  version"** para que el prune libere espacio de verdad (si no, lo borrado
  queda como versiones ocultas que siguen facturando).
- **Planes**: `homelab-diario` (3:00 → local) y `homelab-b2` (4:00 →
  offsite, una hora después para no solapar). Mismos paths y excludes.
- **Retención** en ambos: 7 diarias · 4 semanales · 6 mensuales.
- **Check mensual** en ambos repos releyendo el 25% de los datos
  (b2: día 1 a las 5:00 — sin coste, egress gratis hasta 3× lo almacenado).

## Notificaciones de fallo (ntfy)

Hooks tipo **Shoutrrr** apuntando a ntfy por su **URL interna**
(`ntfy://ntfy:80/<topic>?scheme=http&...`) — ver doc 08: los contenedores
no alcanzan el dominio público (IP de Tailscale). Topic secreto, fuera de Git.

- En los **planes**: `SNAPSHOT_ERROR` + `SNAPSHOT_WARNING`
- En los **repos**: `PRUNE_ERROR` + `CHECK_ERROR`

Probado con condición `SNAPSHOT_SUCCESS` temporal → push recibido en el
móvil, condición retirada después (solo debe sonar cuando algo falle).

## Restauraciones de prueba — verificadas

- **Local**: snapshot `bfa3b152` → `/restore-test`, `diff -rq` limpio.
- **B2**: `README.md` del snapshot `60edce5d` → `/restore-test/b2`,
  `diff` limpio. Nota: lo restaurado pertenece a root (Backrest corre
  como root en el contenedor) → comparar/limpiar con `sudo`.

## Estado 3-2-1

**3** copias (original + HDD + B2) · **2** medios · **1** offsite.
Tamaño actual ~10 MiB → de sobra dentro de los 10 GB gratuitos de B2 (0 €).
