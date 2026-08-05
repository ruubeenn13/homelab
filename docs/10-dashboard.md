# 10 · Dashboard — Homarr

Panel del homelab en `dash.rubenlav.dev`. Se probaron **Homepage** (gethomepage,
config por YAML) y **Homarr** en paralelo; ganó Homarr por su editor visual
drag & drop y las integraciones con datos en vivo. Homepage queda apagada en
`stacks/homepage/` como reserva.

## Configuración

- **Homarr v1.73.0**, clave `SECRET_ENCRYPTION_KEY` en `.env` (y en Bitwarden) —
  cifra las credenciales de integraciones en `appdata/` (gitignored; recuperable
  porque `appdata/` y `.env` entran en el backup diario de Backrest).
- **Integraciones por URL interna** (lección del doc 08 — los contenedores no
  alcanzan `*.rubenlav.dev`): AdGuard `http://adguard:80` (user+pass),
  Traefik `http://traefik:8080` (sin auth), ntfy `http://ntfy:80` (topic),
  Uptime Kuma `http://uptime-kuma:3001` — requirió crear en Kuma una
  **status page** con slug `homelab` (es lo que lee su API).
- **Docker vía socket-proxy** (`DOCKER_HOSTNAMES`/`DOCKER_PORTS`): con
  `CONTAINERS=1` (solo lectura) Homarr muestra el estado de los contenedores;
  sus botones de start/stop no funcionan — decisión consciente, no fallo.
