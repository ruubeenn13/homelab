# CLAUDE.md — homelab

## Qué es
Infraestructura self-hosted en un portátil Asus (Ubuntu Server 24.04 + Docker Compose). Sin Proxmox.

## Decisiones cerradas
- Exposición: cero puertos abiertos. Público → Cloudflare Tunnel · privado → Tailscale · LAN → AdGuard Home.
- Proxy: Traefik v3, wildcard TLS por DNS-01 (Cloudflare). Dominio: rubenlab.dev.
- CI/CD: runner self-hosted de GitHub Actions. Sin Jenkins.
- Actualizaciones: versiones fijadas + Diun (solo notifica). Sin Watchtower. Nunca `latest` en BDs.
- Backups: dump de BDs + restic → HDD local (/mnt/datos/backups) + Backblaze B2. Restore de prueba mensual.
- BDs: una por stack. MariaDB 11 para GymProFit/bot; PostgreSQL solo si un proyecto lo pide.
- Discos: NVMe 1TB (WD SN770) = sistema, Docker y datos calientes · HDD 1TB (Toshiba, en /mnt/datos) = backups locales y bulk.

## Normas del repo
- Un directorio por stack en `stacks/`: `compose.yml` + `.env` (fuera de Git) + README corto.
- README raíz actualizado en cada cambio relevante.
- Decisiones de arquitectura en `docs/decisions/`, una nota corta por decisión.
- Secretos jamás en Git: respetar `.gitignore` (.env, acme.json, data/, backups/, *.key).
- Repo público (portfolio): secretos jamás en Git, `.env.example` por stack, push protection activa en GitHub.
