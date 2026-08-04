# 01 · Hardware

Servidor: portátil Asus reutilizado (~2020) funcionando 24/7 sin pantalla ni teclado.

## Especificaciones reales

| Componente | Detalle |
|---|---|
| CPU | Intel Core i7-8750H (8ª gen) · 6 núcleos / 12 hilos · 45 W |
| iGPU | Intel UHD 630 (QuickSync disponible) |
| RAM | 16 GB DDR4-2666 (2×8 GB Samsung) |
| Disco sistema | NVMe WD Black SN770 1 TB (añadido a posteriori) |
| Disco datos | HDD Toshiba MQ04ABF100 1 TB · 5400 rpm (nativo) |
| Red | Ethernet Gigabit (objetivo) · Wi-Fi (temporal) |
| SO | Ubuntu Server 24.04 LTS |

Pendiente de confirmar: modelo exacto del portátil, salud de la batería, opciones de BIOS
(encendido tras corte de luz, límite de carga) y posible GPU NVIDIA dedicada (`lspci`).

## La lección: verificar antes de planificar

Toda la planificación inicial asumía "12ª gen, 8 GB de RAM, SSD SATA de 500 GB".
La realidad, descubierta ya con el servidor en marcha:

- CPU de 8ª gen (2018), no 12ª — pero de gama alta: mejor de lo esperado.
- 16 GB de RAM, no 8 — la ampliación "urgente" dejó de serlo.
- El disco nativo era un HDD mecánico de 1 TB, no un SSD SATA de 500 GB.

Moraleja: `lscpu`, `free -h`, `lsblk` y `sudo dmidecode` **antes** de decidir arquitectura.

## Un portátil como servidor

Ventajas: batería integrada que actúa de SAI ante microcortes, bajo consumo, silencio, coste cero.

Contrapartidas gestionadas:
- Tapa cerrada → suspensión: desactivado (ver 03-sistema-base).
- Suspensión/hibernación: enmascaradas en systemd.
- Batería siempre al 100 %: revisión periódica de hinchazón; límite de carga si la BIOS lo permite.
- Térmica: CPU de 45 W — equipo elevado, rejillas libres, limpieza de ventiladores pendiente.
- Discos de consumo: monitorización SMART prevista (smartmontools).

## Reparto de discos

- **NVMe 1 TB** → sistema, Docker y datos calientes (bases de datos, fotos).
- **HDD 1 TB** (`/mnt/datos`) → backups locales, media y almacenamiento frío.
- Ambos discos comparten chasis: la copia real vive fuera (Backblaze B2, estrategia 3-2-1).
