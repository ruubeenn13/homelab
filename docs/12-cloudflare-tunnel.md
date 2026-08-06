# 12 · Cloudflare Tunnel — exposición pública selectiva

`cloudflared` en Docker abre una conexión **saliente** hacia Cloudflare:
cero puertos abiertos (intacto) y el CGNAT de Vegafibra da igual. Token del
túnel en `.env` (copia en Bitwarden). Primera ruta pública: ntfy, para que
la familia reciba notificaciones sin Tailscale.

## Enrutado

Ruta en Zero Trust: `ntfy.rubenlav.dev` → `https://traefik:443` con
**Origin Server Name = ntfy.rubenlav.dev** (imprescindible: le dice a
Traefik qué certificado del wildcard servir; sin él, 502). Todo el tráfico
del túnel pasa por Traefik — mismos logs y TLS que el resto. Publicar otro
servicio en el futuro = añadir otra ruta en el panel, mismo patrón.

## Split DNS: un servicio público, el resto privado

- **Fuera de casa**: DNS público de Cloudflare → túnel.
- **En casa**: AdGuard reescribe `*.rubenlav.dev` → IP de Tailscale, con
  **excepción** para `ntfy.rubenlav.dev` usando la respuesta especial `A`
  ("keep A records from the upstream") → resuelve a las IPs públicas del
  túnel para toda la casa. El resto de servicios sigue siendo solo-Tailscale.

## Batalla: el router cachea DNS

Tras añadir la excepción, AdGuard ya respondía bien
(`dig @127.0.0.1` → 188.114.x) pero los móviles seguían recibiendo la IP
de Tailscale: el **router** (por el que pasan los clientes DHCP) tenía la
respuesta vieja cacheada y los routers de operadora no purgan caché →
reinicio del router y resuelto. Diagnóstico en dos comandos:
`dig @127.0.0.1` (AdGuard) vs `dig @192.168.0.1` (router) — si difieren,
es el router.

## App ntfy contra servidor propio

Sin FCM (eso es solo de ntfy.sh), la app usa conexión permanente →
notificación persistente de Android obligatoria. Se oculta desactivando el
canal "Servicio de suscripción" (los mensajes van por otro canal y siguen
llegando). Desactivar optimización de batería para ntfy o los avisos
llegan tarde. Topics secretos, nunca en Git ni publicados.

## Desbloqueado (pendiente de usar)

Webhooks entrantes: bot de Telegram con trigger nativo y webhooks push de
GitHub — siguiente vez que toquemos n8n.

## Segunda ruta: webhooks de n8n (exposición por path)

Ruta `n8n.rubenlav.dev` con **Ruta `^/webhook`** → `https://traefik:443`
(Origin Server Name `n8n.rubenlav.dev`): solo los paths de webhook son
públicos; la interfaz da 404 desde Internet y sigue siendo solo-Tailscale.
Primer consumidor: webhook de GitHub (repo homelab) → push por ntfy al
abrirse issues/PRs o recibir stars. Verificado el circuito completo:
GitHub → Cloudflare → túnel → Traefik → n8n → ntfy → móvil.
