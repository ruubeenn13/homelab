# 13 · Métricas — Prometheus + Grafana (fase 1)

Complementa al doc 08 (Uptime Kuma dice *si* algo está vivo; esto dice
*cómo* está de salud). Stack `monitoring`: **node-exporter** expone las
métricas del host (CPU, RAM, discos, red, temperaturas) montando /proc,
/sys y / en solo lectura; **Prometheus** las recolecta cada 15s con
retención de 15 días (decisión del plan original, para no comerse el
NVMe); **Grafana** las visualiza.

## Detalles de despliegue

- `prometheus.yml` versionado en el repo; los datos en `data/` (gitignored,
  dentro del backup de Backrest).
- Grafana con `user: "0"` para poder escribir en su volumen; Prometheus
  corre como uid 65534 → su directorio de datos necesita
  `chown -R 65534:65534` (batalla real: sin eso, bucle de reinicio con
  "permission denied").
- Contraseña de admin de Grafana: el env `GF_SECURITY_ADMIN_PASSWORD` solo
  aplica en el primer arranque; cambios posteriores con
  `docker exec grafana grafana cli admin reset-admin-password '...'`.
- Data source: `http://prometheus:9090` (URL interna, doc 08).
- Dashboard: **Node Exporter Full** (ID 1860) importado de la comunidad.

## Pendiente (fase 2)

cAdvisor para métricas por contenedor, panel/es embebidos en Homarr, y
alertas de Grafana → ntfy (umbrales de CPU/RAM/disco sostenidos).

## Paneles embebidos en Homarr (fase 1.5)

Grafana con `GF_SECURITY_ALLOW_EMBEDDING=true` + acceso **anónimo de solo
lectura** (`GF_AUTH_ANONYMOUS_ENABLED=true`, rol Viewer) — necesario porque
el iframe de Homarr no puede autenticarse. Riesgo asumido y aceptado:
cualquier dispositivo del tailnet ve las gráficas sin login (tailnet
unipersonal).

Para iframes vale solo la URL de panel suelto
(`/d-solo/<uid>/<slug>?orgId=1&panelId=NN&from=now-6h&to=now&refresh=1m&theme=dark`);
la URL normal del dashboard carga la interfaz entera. En Node Exporter
Full: CPU Basic = panel 77, Memory Basic = 78 (el ID sale abriendo el
panel en View y mirando `viewPanel=` en la URL).

Tarjetas de app en Homarr: el ping de estado sale del contenedor → usar
"URL diferente para ping" con la interna (`http://grafana:3000`), no el
dominio público (doc 08, una vez más).
