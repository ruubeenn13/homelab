# 17 — Cloudflare Access: paneles sin depender de Tailscale

Hasta ahora, ver Homarr, Dozzle o Grafana fuera de casa exigía tener
Tailscale activo. Access añade una capa de login delante del túnel
existente: los paneles son accesibles desde cualquier sitio sin VPN,
pero con un candado real delante, no expuestos a pelo.

## Tres piezas independientes (la parte que costó entender)

Access **no enruta tráfico**: solo decide quién puede pasar. El camino
real hasta el contenedor lo definen otras dos piezas, y las tres viven en
sitios distintos del panel de Cloudflare:

1. **Access → Aplicaciones**: la política de identidad (quién entra).
2. **Redes → Conectores → [túnel] → Rutas de aplicaciones publicadas**
   (antes "Public Hostnames" en las guías viejas): a qué contenedor llega
   el tráfico (Host → https://traefik:443).
3. **DNS → Registros**: quién resuelve el nombre hacia la red de
   Cloudflare (CNAME a `<id>.cfargotunnel.com`, proxy naranja activado).

Las tres tienen que estar bien para que un panel funcione desde fuera.

## Aplicaciones de Access

- **Paneles homelab** — destino `*.rubenlav.dev`. Política **Solo Ruben**:
  Include → Emails → el email de Ruben, acción Permitir, sesión 1 mes.
- **Paso libre (ntfy + webhooks)** — destinos `ntfy.rubenlav.dev` (ruta
  completa) y `n8n.rubenlav.dev/webhook` (solo esa ruta). Política
  **Paso libre**: Include → Everyone, acción **Omitir/Bypass** (no
  Permitir). Necesaria porque la app de ntfy de los padres y los webhooks
  de GitHub no pueden hacer login interactivo. Access prioriza la app más
  específica, así que estas dos rutas quedan sin candado y todo lo demás
  cae bajo "Paneles homelab".

## Ruta comodín en el túnel

- `Rutas de aplicaciones publicadas` → nueva fila: Host `*.rubenlav.dev`
  → Servicio `https://traefik:443` → **No TLS Verify** activado (Traefik
  expone HTTPS puertas adentro con certificado autofirmado; sin este
  flag el túnel rechaza la conexión).

## DNS

- El registro comodín `*.rubenlav.dev` era un **A antiguo** apuntando a
  la IP de Tailscale, arrastrado desde el montaje inicial del proyecto
  (antes de que existiera el túnel). Se sustituyó por un **CNAME** al
  mismo destino `.cfargotunnel.com` que ya usaban ntfy y n8n, con proxy
  (nube naranja) activado. Sin el proxy activo, el registro se queda en
  modo "Solo DNS" y no enruta al túnel.

## Batallita: la UI de Cloudflare se renombra sola

Zero Trust mueve nombres entre versiones: "Tunnels" ahora es
"Conectores"; "Rutas de nombre de host" (la pantalla que más se parece a
la vieja "Public Hostnames") queda vacía si el túnel usa token — el
enrutado real vive en **"Rutas de aplicaciones publicadas"**. Si algo no
aparece donde debería, sospechar primero que Cloudflare le ha cambiado
el nombre, no que falte configurar.

## Verificado

`dozzle.rubenlav.dev` desde móvil, datos, sin Tailscale: pide login en
`rubenlav.cloudflareaccess.com` (código al email) y tras autenticar entra
con normalidad. `ntfy.rubenlav.dev` abre directo, sin login.

## Pendiente

- Actualizar la imagen de `cloudflared` (aviso de versión visto en el
  panel; sin urgencia, no bloquea nada).
