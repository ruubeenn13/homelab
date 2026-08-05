# 03 · Sistema base

Configuración del SO para operar 24/7 sin pantalla, administrado solo por SSH.

## Actualización inicial

```bash
sudo apt update && sudo apt upgrade -y
```

## Portátil en modo servidor: tapa y suspensión

Por defecto, cerrar la tapa suspende la máquina — inaceptable en un servidor.

En `/etc/systemd/logind.conf` (descomentar y ajustar):

```ini
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```

Aplicar con `sudo systemctl restart systemd-logind` y rematar enmascarando
cualquier vía de suspensión:

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

Verificado en real: el servidor opera con la tapa cerrada.

## Firewall (UFW)

```bash
sudo ufw allow ssh
sudo ufw enable
```

En ese orden — habilitar sin permitir SSH primero equivale a cerrarse la puerta
desde dentro. Política: default deny entrante; de momento solo el 22 abierto.

**Nota conocida**: los puertos publicados por Docker (`ports:`) puentean UFW.
Irrelevante en el diseño final (cero puertos publicados tras Traefik + Tunnel),
pero importante saberlo mientras existan accesos temporales tipo `:8080`.

## Actualizaciones de seguridad automáticas

```bash
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades   # → Yes
```

Los parches de seguridad del SO se aplican solos. Las actualizaciones de
contenedores, en cambio, serán siempre manuales y deliberadas (Diun avisará).

## Docker

Del repositorio oficial (nunca el snap ni el paquete `docker.io` de Ubuntu):

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker ruben   # requiere relogin
```

## Reglas de operación

- Trabajar SIEMPRE como usuario normal; `sudo` puntual por comando. Nada de `sudo su`.
- Git jamás con sudo (los archivos quedarían en propiedad de root).
- Apagado ordenado: `sudo poweroff`. Nunca el botón, salvo cuelgue total.

## Batalla: batería crítica sin tapa cerrada

El mask de sleep de este documento bloquea la tapa, pero UPower dispara su
propia acción ante **batería crítica** por una vía distinta — bypassea el
mask y puede colar un `hybrid-sleep` (verificado en real, 05/08/2026).
Bloquear sleep sin más tampoco vale: si a UPower no le queda ninguna vía,
la batería se agota igual y el equipo muere en seco (riesgo para los
volúmenes de Docker). La solución es que ante batería crítica **apague
limpio**, no que intente dormir.

`/etc/UPower/UPower.conf`: `CriticalPowerAction=PowerOff`,
`PercentageAction=5`, `PercentageCritical=8`, `PercentageLow=20`.

**Aviso previo** (antes de llegar a ese punto): `/usr/local/bin/battery-watch.sh`
+ `battery-watch.timer` (cada 5 min) — si detecta `discharging` y ≤25%,
push a ntfy vía la URL pública (el host sí resuelve `*.rubenlav.dev`, a
diferencia de los contenedores — doc 08). Se resetea solo al reconectar
el cargador.

Host en `Europe/Madrid` (antes UTC — los contenedores ya llevaban
`TZ=Europe/Madrid` propio, esto solo afectaba a logs del sistema).

## Aviso de disco lleno

Mismo patrón que el de batería — `/usr/local/bin/disk-watch.sh` +
`disk-watch.timer` (cada 15 min), vigila `/` y `/mnt/datos`, push a ntfy
al cruzar el 85% de uso, se resetea solo si baja de nuevo.
