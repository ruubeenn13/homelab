# 06 · Traefik — reverse proxy y HTTPS

Todos los servicios web pasan a servirse como `https://<servicio>.rubenlav.dev`
con certificado wildcard de Let's Encrypt. Sin puertos publicados por servicio.

## Arquitectura

- **Traefik v3** escucha en 80/443 (80 solo redirige a 443).
- **Certificado wildcard** (`rubenlav.dev` + `*.rubenlav.dev`) por DNS-01 contra
  Cloudflare: un solo certificado para todo, renovación automática (~60 días).
- **socket-proxy** (Tecnativa v0.4.2): Traefik no toca el socket de Docker;
  consulta contenedores por red interna con permiso de solo lectura (CONTAINERS=1).
- **Red `proxy`** (externa): la comparten Traefik y cada servicio con web.
- `exposedbydefault=false`: nada se publica sin pedirlo con etiquetas.

## DNS: nombres públicos, servicios privados

En Cloudflare: `A * → 100.75.176.61` y `A @ → 100.75.176.61` (la IP Tailscale
del servidor, "Solo DNS"). Cualquiera puede resolver los nombres; solo los
dispositivos del tailnet pueden llegar. Cero exposición pública.

## Añadir un servicio nuevo (el patrón)

Red `proxy` + etiquetas en su compose:

```yaml
labels:
  - traefik.enable=true
  - traefik.http.routers.<nombre>.rule=Host(`<nombre>.rubenlav.dev`)
  - traefik.http.routers.<nombre>.entrypoints=websecure
  - traefik.http.services.<nombre>.loadbalancer.server.port=<puerto-interno>
```

Sin `ports:`, sin DNS nuevo, sin certificados. Dozzle fue el primero en migrar.

## Batallas de esta instalación (documentadas para el futuro)

1. **Errata en un flag** (`certificationresolvers`) → Traefik en bucle de
   reinicio con "field not found". Los flags largos se copian, no se teclean.
2. **La red del apartamento bloquea DNS externo** (puerto 53 capado) y su
   resolver cacheó negativos del dominio recién nacido → la autocomprobación
   de propagación fallaba (NXDOMAIN eterno). Solución en dos capas:
   `dnschallenge.resolvers=1.1.1.1:53,8.8.8.8:53` + `propagation.disablechecks=true`
   (Let's Encrypt valida por su cuenta contra los autoritativos de Cloudflare;
   la comprobación local es prescindible).
3. **En el PC**, mismo bloqueo de DNS → activado DNS-sobre-HTTPS en el navegador
   (Cloudflare). En la red definitiva, AdGuard será el resolver del tailnet.

## Verificación

- `https://traefik.rubenlav.dev` → dashboard con candado válido.
- `https://dozzle.rubenlav.dev` → Dozzle migrado, puerto 8080 eliminado.
- `acme.json` (16 KB) con `"main": "rubenlav.dev"` — fuera de Git (.gitignore).
