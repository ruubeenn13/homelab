# Homelab

Infraestructura self-hosted sobre un portátil Asus reutilizado — Ubuntu Server 24.04 + Docker Compose, administrado 100 % por SSH y documentado paso a paso.

**Estado**: servidor base operativo · primer stack en marcha · fase de infraestructura en curso.

## Documentación

| Doc | Contenido |
|---|---|
| [01 · Hardware](docs/01-hardware.md) | Especificaciones reales y lecciones de verificar antes de planificar |
| [02 · Instalación](docs/02-instalacion-ubuntu.md) | Ubuntu Server desde USB: decisiones y trampas reales |
| [03 · Sistema base](docs/03-sistema-base.md) | Modo headless, firewall, actualizaciones automáticas, Docker |
| [04 · Almacenamiento](docs/04-almacenamiento.md) | LVM, segundo disco, fstab, rotación de logs |

Las decisiones de arquitectura viven en [`docs/decisions/`](docs/decisions/) y el contexto operativo en [`CLAUDE.md`](CLAUDE.md).

## Stacks

| Stack | Estado | Qué hace |
|---|---|---|
| [dozzle](stacks/dozzle/) | ✅ en marcha | Visor web de logs de contenedores |

## Arquitectura (resumen)

- **Exposición**: cero puertos abiertos al exterior — Cloudflare Tunnel (público) · Tailscale (privado) · AdGuard (LAN).
- **Proxy**: Traefik v3 con wildcard TLS (DNS-01).
- **CI/CD**: GitHub Actions con runner self-hosted (repos privados) + despliegue pull en este repo.
- **Backups**: 3-2-1 — dumps + restic → HDD local + Backblaze B2, con restauración de prueba mensual.
- **Actualizaciones**: versiones fijadas + Diun (notifica, no actualiza).

## Hoja de ruta

Traefik → AdGuard → Uptime Kuma → migración del bot de Discord → GymProFit staging → CI/CD → backups → Tailscale → monitorización → **Immich**.
