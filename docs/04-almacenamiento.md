# 04 · Almacenamiento

Dos discos, dos papeles: NVMe para lo vivo, HDD para lo frío.

## Ampliar la raíz a todo el NVMe

El instalador de Ubuntu deja la raíz en 100 GB y el resto del volumen LVM en
reserva, a propósito. Ampliación en caliente, sin reiniciar:

```bash
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```

Resultado: `/` pasó de 98 GB a 914 GB con el sistema en marcha. (La razón de
haber elegido LVM en la instalación.)

## El HDD como disco de datos

El Toshiba de 1 TB conservaba el NTFS del Windows anterior. Borrado y formateo:

```bash
sudo wipefs -a /dev/sda
sudo parted /dev/sda --script mklabel gpt mkpart datos ext4 0% 100%
sudo mkfs.ext4 -L datos /dev/sda1
```

## Montaje automático (fstab)

En `/etc/fstab`, identificando el disco por UUID (los nombres tipo `sda` pueden
bailar entre arranques; el UUID no):
**`nofail` es la opción crítica en un servidor headless**: si el HDD muere, el
sistema arranca igual en vez de quedarse colgado esperándolo en un boot al que
no hay pantalla que atender.

```bash
sudo systemctl daemon-reload && sudo mount -a
```

Estructura creada: `/mnt/datos/{backups,media,archivos}`, propiedad del usuario.

## Rotación de logs de Docker

El fallo clásico nº 1 de un homelab: el disco lleno de logs a los meses.
Cortado de raíz en `/etc/docker/daemon.json` antes del primer contenedor:

```json
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" }
}
```

Máximo 30 MB de logs por contenedor (3 × 10 MB en rotación).

## Pendiente en este frente

- smartmontools + alertas de espacio (llegarán con la monitorización).
- Backups 3-2-1: dumps + restic → `/mnt/datos/backups` + Backblaze B2 (doc propio).
