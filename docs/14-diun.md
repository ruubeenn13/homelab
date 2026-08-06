# 14 · Diun — vigilancia de versiones

Cierra el ciclo de la norma de **versiones fijadas**: los tags pinneados
dan control pero nadie avisa de novedades — Diun comprueba a diario (7:00,
antes de los partes) si los registries publicaron versiones nuevas de las
imágenes en uso y avisa por ntfy al topic personal. Solo notifica; la
actualización sigue siendo manual y deliberada (se descartó Watchtower
por auto-actualizar sin supervisión).

- Descubrimiento vía **socket-proxy**: `CONTAINERS=1` no basta — Diun
  inspecciona imágenes y necesitó abrir `IMAGES=1` en Tecnativa (403
  "Request forbidden" como síntoma). Sigue siendo solo lectura; los POST
  continúan bloqueados.
- `WATCHBYDEFAULT=true`: vigila todo contenedor presente sin etiquetas.
- Primera pasada = línea base (15 imágenes), sin notificar; avisa solo de
  cambios posteriores. Estado en `data/` (gitignored, dentro de Backrest).
- Canal verificado con `docker exec diun diun notif test`.
