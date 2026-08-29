# 19 — Crafty Controller: servidor de Minecraft

Servidor de Minecraft para Ruben y su pareja, gestionado con Crafty Controller.
Modpack custom en Fabric, pensado para hardware modesto tras comprobar que un
pack ya hecho (Cozy Experience, 300+ mods) no aguantaba en el portátil de mi
pareja (Intel i5-1035G1, Intel UHD G1).

## Arquitectura

- **Crafty Controller** (`stacks/crafty-controller/`), imagen oficial, red
  `proxy`. Panel en `https://100.75.176.61:8443` (Tailscale) — sin dominio
  propio por Traefik; `crafty.rubenlav.dev` queda aparcado a propósito.
- Minecraft se expone por Cloudflare DNS (no Tunnel): registro `mc` en modo
  DNS only (nube gris) → IP pública, puerto `25565` reenviado en el router.
  - Desde fuera: `mc.rubenlav.dev` o `193.228.204.206:25565`
  - Desde la LAN: `192.168.18.6:25565`
- Solo `compose.yml` está en Git. `docker/servers`, `docker/config`,
  `docker/logs` y `docker/import` van en `.gitignore` — el mundo y los mods
  pesan demasiado para un repo, y `docker/config` guarda credenciales del panel.

## El modpack — "Charco y Sendero"

- Fabric 26.1.2, 63 mods, verificados uno a uno contra CurseForge, no por
  descripción de marketing.
- Nombre interno del servidor y del mundo: `Pitolandia`. El MOTD que ven los
  jugadores es "Charco y Sendero".
- Mods sueltos añadidos después (Clumps, CarryOn): se suben directo a
  `mods/` vía el gestor de archivos de Crafty. Fabric solo los carga al
  reiniciar, no en caliente.

## Whitelist y permisos

- `whitelist.json`: `d4rkl0k` (yo) y `RanitaAdorable`.
- Admin: `/op d4rkl0k` desde consola — efecto inmediato, sin reinicio.

## Backups (Backrest)

Dos planes nuevos, mismo patrón 3-2-1 que el resto del homelab:

| Plan | Repo | Horario | Retención |
|---|---|---|---|
| `minecraft-local` | local | 3:00 AM | 7d / 4 sem / 6 mes |
| `minecraft-b2` | b2 | 4:00 AM | 7d / 4 sem / 6 mes |

Rutas respaldadas (Backrest ve `/opt/homelab` como `/userdata/homelab` dentro
de su propio contenedor), todas bajo
`.../crafty-controller/docker/servers/59c66e52-a8d5-4cb4-8028-b707bc1c97b4/`:

- `world`
- `whitelist.json`
- `ops.json`
- `banned-ips.json`
- `banned-players.json`
- `server.properties`

`mods/` y `libraries/` no se respaldan — se recuperan del export de
CurseForge.

## Monitorización y alertas

- **Uptime Kuma**: monitor TCP al `25565`, apuntando al nombre del
  contenedor (`crafty-controller`), no a la IP LAN — mismo problema de red
  entre contenedores que con Tailscale. Notificación ntfy nativa desactivada
  aquí, para no duplicar con n8n.
- **n8n "Minecraft - Alertas"**: Kuma dispara un Webhook interno
  (`http://n8n:5678/webhook/minecraft-status`) → mensaje con emojis → ntfy.
- **n8n "Parte diario - Minecraft"**: cron `0 8 * * *`, consulta la API de
  Crafty (`/api/v2/servers/.../stats`, token con permisos de administrador
  completo — con permisos mínimos da acceso denegado) → jugadores, CPU, RAM,
  tamaño del mundo, uptime → ntfy.

## Datapacks

Van por mundo, no por perfil: `world/datapacks/`, no `mods/`. Se activan sin
reiniciar, con `reload` desde consola. No hacen falta los mods "loader" que
sugiere CurseForge — son solo para su launcher local.

## Lecciones aprendidas

- Un contenedor no siempre llega a la IP LAN del host para el puerto de otro
  contenedor. Solución fiable: nombre del contenedor en la misma red Docker.
- Fabric solo carga mods al arrancar; los datapacks sí se recargan con
  `reload` sin reiniciar.
- `server-icon.png`: nombre exacto, 64×64 px, en la raíz del servidor — el
  `icon.png` del export de CurseForge es el icono del perfil, no el que lee
  el protocolo de Minecraft.
- La API de Crafty exige token con permisos de administrador completo para
  el endpoint de stats; los permisos "mínimos" documentados no bastan.

## Pendiente

- CarryOn instalado pero sin funcionar — investigar más adelante.
- Backup nocturno integrado en el parte diario — Backrest no tiene API REST
  sencilla (gRPC por debajo).
- TPS real del servidor — necesita RCON, no activado.
- Tiempo de juego por jugador — necesita parsear logs.
