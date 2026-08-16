# 18 — Troubleshooting: servidor sin red al cambiar de ubicación

Síntoma: SSH, Tailscale, ntfy y todos los paneles caídos a la vez tras
mover el portátil-servidor a una red distinta (p. ej. entre Elche y
Crevillente). No es un fallo de Tailscale, Access ni del túnel — esas
capas dependen de que el servidor tenga salida a internet primero.

## Diagnóstico

Sin SSH disponible (el propio problema lo bloquea), hace falta pantalla
y teclado físicos en el servidor:

```bash
ip -br a | grep wlo1
```

- `DOWN` sin más → probar `sudo rfkill unblock all` y
  `sudo ip link set wlo1 up` (radio bloqueada por software).
- `NO-CARRIER,UP` → la tarjeta está activa pero no asociada a ningún
  WiFi: netplan no encuentra ninguna red guardada en alcance. Es el caso
  típico al llegar a una ubicación nueva.

Confirmar con los logs:
```bash
sudo journalctl -b | grep -i wlo1 | tail -40
```
Busca reintentos repetidos de conexión a un SSID que no está en rango.

## Causa real (este caso)

`/etc/netplan/50-cloud-init.yaml` solo tenía guardada la red del Piso
Arenales. Al mover el servidor a Crevillente, la tarjeta reintentaba esa
red sin descanso, nunca la de aquí.

## Fix — añadir la red nueva (una sola vez por ubicación)

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

Añadir un bloque de `access-points` más, con la misma sangría que los
existentes:
```yaml
        "NOMBRE_RED":
          auth:
            key-management: "psk"
            password: "contraseña"
```
Guardar (`Ctrl+O`, Enter, `Ctrl+X`) y aplicar:
```bash
sudo netplan apply
```

## Nota de hardware

Preferir siempre la banda **2.4GHz** sobre la 5G para el servidor: más
alcance y mejor penetración en paredes. La 5G puede perder cobertura
si el servidor no está muy cerca del router.
