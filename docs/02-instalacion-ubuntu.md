# 02 · Instalación de Ubuntu Server 24.04

Instalación desde USB (Ventoy) con destino el NVMe. Duración real: ~30 min.

## Preparación

- ISO: `ubuntu-24.04.x-live-server-amd64.iso` desde releases.ubuntu.com (ojo: el
  enlace por defecto puede llevar a versiones antiguas o al `.torrent`).
- USB con Ventoy: se arrastra la ISO y sirve para futuras ISOs sin reformatear.
- Arranque: menú de boot de Asus con `Esc` → entrada "UEFI: <usb>".

## Decisiones tomadas en el instalador

| Pantalla | Elección | Por qué |
|---|---|---|
| Base | Ubuntu Server (no minimized) | Herramientas básicas incluidas |
| Third-party drivers | No | Hardware soportado de serie |
| Red | DHCP por Wi-Fi (temporal) | Instalación fuera de la red definitiva |
| Proxy | Vacío | Red doméstica |
| Instalador | Actualizar a la versión nueva | Correcciones del propio instalador |
| Disco | **NVMe** · disco entero · LVM · sin cifrar | Ver nota abajo |
| Ubuntu Pro | Skip | Innecesario para este uso |
| SSH | **Install OpenSSH server** ✓ · con contraseña | Las claves llegan después |
| Featured snaps | Ninguno | Todo irá en Docker con versiones fijadas |

**Sin cifrado LUKS**: un servidor headless no puede teclear la passphrase en cada
arranque; tras un corte de luz quedaría bloqueado esperando un teclado.

**LVM sí**: permitió después ampliar la raíz en caliente (ver 04-almacenamiento).

## Trampas reales de esta instalación

1. **El instalador preselecciona el disco equivocado.** Ofrecía el HDD Toshiba;
   el destino correcto era el NVMe (desplegable con 3 discos, incluido el propio USB).
   Identificar SIEMPRE los discos por modelo antes de confirmar.
2. **La IP de DHCP cambia entre reinicios** (pasó de .110 a .109). Hasta tener
   reserva DHCP en el router definitivo: comprobar con `ip a` tras cada arranque.
3. El primer login puede quedar "enterrado" entre mensajes de cloud-init:
   Enter un par de veces y aparece el prompt.

## Resultado

Sistema accesible por SSH desde el primer arranque: `ssh ruben@<ip>`.
A partir de aquí, el portátil no volvió a necesitar pantalla ni teclado.
