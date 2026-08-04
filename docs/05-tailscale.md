# 05 · Tailscale — acceso remoto privado

Red privada (tailnet) entre el servidor y mis dispositivos. Cero puertos abiertos
en el router: cada máquina establece conexiones salientes cifradas (WireGuard por
debajo) y Tailscale las cose entre sí.

## Por qué Tailscale y no WireGuard puro / puertos abiertos

- Funciona detrás de CGNAT (estado del ISP aún sin confirmar) y en cualquier red.
- Configuración de minutos frente a gestionar claves y peers a mano.
- IP fija por dispositivo (`100.x.x.x`) y MagicDNS: `ssh ruben@homelab` desde
  cualquier parte del mundo, sin importar la red local del servidor.

## Instalación (en el host, no en Docker — es infraestructura del sistema)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh
```

El flag `--ssh` activa Tailscale SSH: acceso al servidor autenticado por la
identidad del tailnet, funcione o no el puerto 22 tradicional.

## Estado

- Cuenta: plan Personal (login con GitHub).
- Dispositivos: `homelab` (servidor) + PC. El móvil, pendiente.
- IP fija del servidor: `100.75.176.61` · MagicDNS: `homelab`.

## Nota de operación

La IP LAN (DHCP) puede cambiar entre reinicios; la de Tailscale, nunca.
Referencia canónica para SSH y servicios privados: el nombre `homelab`.
