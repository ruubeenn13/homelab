# 08 · Monitorización — Uptime Kuma + ntfy

Vigilancia de los servicios propios con aviso push al móvil ante caídas.

## Uptime Kuma (v2.5.0)

Panel en `uptime.rubenlav.dev`. Base de datos SQLite (suficiente para monitorización
propia; MariaDB queda reservada para proyectos con datos reales, según CLAUDE.md).

**4 monitores activos:**
- Traefik, Dozzle, AdGuard — tipo HTTP(s)
- Servidor (contenedor `traefik`) — tipo Docker Container, vía socket montado

## ntfy (v2.26.0)

Servidor de notificaciones push propio en `ntfy.rubenlav.dev`. Sin autenticación:
la seguridad es un **topic no adivinable** (`openssl rand -hex 4`), patrón estándar
de ntfy para uso personal — cualquiera que conozca el topic exacto puede publicar
o suscribirse, así que se trata como un secreto (no queda en Git, no se comparte).

App móvil **ntfy** (no confundir con la app cliente de Uptime Kuma, que solo
consulta el dashboard y no gestiona notificaciones push).

## Batalla recurrente: contenedores y Tailscale no se mezclan bien

Traefik, Dozzle, AdGuard y ntfy resuelven todos a la IP de Tailscale del propio
servidor. Un contenedor Docker corriente **no puede alcanzar esa interfaz**,
aunque el host sí — mismo servidor, redes distintas a ojos de Docker.

Síntoma: `curl` a `https://servicio.rubenlav.dev` desde dentro de un contenedor
se cuelga hasta timeout (`000`); el mismo curl desde el host funciona perfecto.

**Solución aplicada en todos los casos**: cuando un contenedor necesita hablar
con otro del mismo servidor, usar el **nombre del contenedor + puerto interno**
por la red `proxy` de Docker, nunca el dominio público:

| Servicio | URL pública (para ti) | URL interna (contenedor→contenedor) |
|---|---|---|
| Traefik | `https://traefik.rubenlav.dev` | `http://traefik:8080` *(requiere `--api.insecure=true`, solo accesible dentro de la red Docker)* |
| Dozzle | `https://dozzle.rubenlav.dev` | `http://dozzle:8080` |
| AdGuard | `https://adguard.rubenlav.dev` | `http://adguard:80` |
| ntfy | `https://ntfy.rubenlav.dev` | `http://ntfy:80` |

Diagnóstico rápido para el futuro:
```bash
docker exec <contenedor> curl -s -o /dev/null -w "%{http_code}\n" --max-time 5 <url>
```
`000` = no conecta (probable problema de red/Tailscale); `200` = todo bien.

## Notificaciones

Canal ntfy configurado como predeterminado — se aplica automáticamente a
monitores nuevos. Prioridad máxima en eventos de caída, normal en recuperación.

## Verificación

- Test de notificación desde Uptime Kuma → llega al móvil en 1-2 s.
- `docker stop <contenedor>` de prueba → aviso de caída en <60 s (intervalo de
  chequeo) → `docker start` → aviso de recuperación.
