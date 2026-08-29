# Homelab

Infraestructura self-hosted sobre un portátil Asus reutilizado — Ubuntu Server 24.04 + Docker Compose, administrado 100 % por SSH y documentado paso a paso.

**Estado**: infraestructura estable en producción — 14 stacks en marcha, backups 3-2-1 verificados, monitorización activa. Fase actual: documentación al día y mejoras incrementales.

## Documentación

| Doc | Contenido |
|---|---|
| [01 · Hardware](docs/01-hardware.md) | Especificaciones reales y lecciones de verificar antes de planificar |
| [02 · Instalación](docs/02-instalacion-ubuntu.md) | Ubuntu Server desde USB: decisiones y trampas reales |
| [03 · Sistema base](docs/03-sistema-base.md) | Modo headless, firewall, actualizaciones automáticas, Docker |
| [04 · Almacenamiento](docs/04-almacenamiento.md) | LVM, segundo disco, fstab, rotación de logs |
| [05 · Tailscale](docs/05-tailscale.md) | VPN de malla como único acceso remoto, sin puertos abiertos |
| [06 · Traefik](docs/06-traefik.md) | Reverse proxy, TLS wildcard vía DNS-01, socket-proxy |
| [08 · Monitorización](docs/08-monitorizacion.md) | Uptime Kuma + ntfy: disponibilidad y notificaciones push |
| [09 · Backups](docs/09-backups.md) | Backrest + restic, local y Backblaze B2, restauración verificada |
| [10 · Dashboard](docs/10-dashboard.md) | Homarr como panel de inicio de todos los servicios |
| [11 · Automatización](docs/11-n8n.md) | n8n: precios diarios, partes diarios, alertas de error |
| [12 · Cloudflare Tunnel](docs/12-cloudflare-tunnel.md) | Qué se expone al público y qué se queda solo en Tailscale |
| [13 · Métricas](docs/13-monitorizacion-metricas.md) | Prometheus + Grafana, fase 1 |
| [14 · Diun](docs/14-diun.md) | Avisa de imágenes Docker desactualizadas, no actualiza solo |
| [15 · GymProBot](docs/15-bot-cicd.md) | MySQL + CI/CD: primer servicio de aplicación del homelab |
| [16 · Vigilancia ampliada](docs/16-vigilancia-ampliada.md) | SMART de discos, heartbeats adicionales, notificaciones JSON |
| [17 · Cloudflare Access](docs/17-cloudflare-access.md) | Paneles protegidos sin depender de Tailscale |
| [18 · Troubleshooting de red](docs/18-troubleshooting-red.md) | Diagnóstico cuando el servidor pierde red al cambiar de sitio |

Las decisiones de arquitectura viven en [`docs/decisions/`](docs/decisions/) y el contexto operativo en [`CLAUDE.md`](CLAUDE.md).

## Stacks

| Stack | Estado | Qué hace |
|---|---|---|
| [traefik](stacks/traefik/) | ✅ en marcha | Reverse proxy, TLS wildcard, socket-proxy delante del socket de Docker |
| [adguard](stacks/adguard/) | ✅ en marcha | DNS y rewrites `*.rubenlav.dev` en la LAN |
| [monitoring](stacks/monitoring/) | ✅ en marcha | Prometheus + Grafana + node-exporter + cAdvisor |
| [uptime-kuma](stacks/uptime-kuma/) | ✅ en marcha | Monitores de disponibilidad |
| [ntfy](stacks/ntfy/) | ✅ en marcha | Notificaciones push (alertas, precios, partes diarios) |
| [n8n](stacks/n8n/) | ✅ en marcha | Automatizaciones y workflows |
| [backrest](stacks/backrest/) | ✅ en marcha | Backups restic — local y Backblaze B2 |
| [homarr](stacks/homarr/) | ✅ en marcha | Dashboard de servicios |
| [diun](stacks/diun/) | ✅ en marcha | Vigilancia de versiones de imágenes Docker |
| [dozzle](stacks/dozzle/) | ✅ en marcha | Visor web de logs de contenedores |
| [cloudflared](stacks/cloudflared/) | ✅ en marcha | Túnel para exposición pública selectiva |
| [mysql](stacks/mysql/) | ✅ en marcha | Base de datos del bot de Discord |
| [gymprofit-bot](stacks/gymprofit-bot/) | ✅ en marcha | Bot de Discord de GymProFit, con CI/CD |
| crafty-controller | ✅ en marcha | Servidor de Minecraft — pendiente de subir el stack a este repo y documentar (doc 19) |

## Arquitectura (resumen)

- **Exposición**: cero puertos abiertos al exterior — Cloudflare Tunnel (público) · Tailscale (privado) · AdGuard (LAN).
- **Proxy**: Traefik v3 con wildcard TLS (DNS-01).
- **CI/CD**: GitHub Actions con runner self-hosted (repos privados) + despliegue pull en este repo.
- **Backups**: 3-2-1 — dumps + restic → HDD local + Backblaze B2, con restauración de prueba mensual.
- **Actualizaciones**: versiones fijadas + Diun (notifica, no actualiza).

## Hoja de ruta

GymProFit staging → documentar Crafty/Minecraft (doc 19) → subir stack de Crafty a Git → Immich.
