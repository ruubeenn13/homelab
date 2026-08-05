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
