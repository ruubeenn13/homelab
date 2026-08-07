# 15 — GymProBot: MySQL y despliegue continuo (CI/CD)

Primer servicio "de aplicación" del homelab: el bot de Discord de GymProFit
(`github.com/ruubeenn13/gymprofit-bot`, Java 21 + JDA), con su base de datos y
un pipeline que despliega solo: **push a main → tests en GitHub → deploy en el
servidor → aviso ntfy**.

## MySQL 8.4 LTS (`stacks/mysql/`)

- **¿Por qué MySQL y no MariaDB?** El bot usa `mysql-connector-j` + `flyway-mysql`.
  Desde Flyway 10, MariaDB es un plugin separado: arrancar contra MariaDB habría
  exigido tocar el `pom.xml` y validar 38 migraciones en otro motor. En una
  migración, cuantas menos variables cambien a la vez, mejor.
- Sin puertos publicados: solo accesible desde la red Docker `backend`.
- Healthcheck con `mysqladmin ping` (la imagen oficial no trae script propio).
- Gotcha 1: con `caching_sha2_password` y sin TLS (red interna), el driver JDBC
  necesita `allowPublicKeyRetrieval=true` en la URL.
- Gotcha 2: `mysqldump` sin privilegio `PROCESS` falla al volcar tablespaces →
  `--no-tablespaces` (sección innecesaria para InnoDB normal).

## Stack del bot (`stacks/gymprofit-bot/`)

- Imagen **local** `gymprofit-bot:latest`: la construye el pipeline en el servidor;
  el compose solo la consume (separación build/run).
- Redes: `backend` (BD) y `proxy` (para que Uptime Kuma vigile `/health`).
- Secretos en `.env` del servidor, fuera de git. Flyway crea el esquema al arrancar.

## Runner self-hosted + pipeline

- Runner en `/opt/actions-runner` como servicio systemd (usuario `ruben`, ya en
  el grupo `docker`). Fuera del repo y del backup: se reinstala en minutos.
- **Repo público endurecido**: Actions → "Require approval for all outside
  collaborators"; el deploy solo se dispara tras CI verde de un push a `main`
  (`workflow_run`), nunca desde PRs de forks.
- `deploy.yml`: checkout del `head_sha` validado por CI → `docker build` →
  `compose up -d --force-recreate` → `image prune` → ntfy (🚀 éxito / 🚨 fallo).
- El mensaje del commit se pasa al aviso vía `env:` (nunca interpolado en el
  script): en un runner self-hosted, un commit malicioso no debe poder inyectar
  comandos.

## Backup consistente de la BD

- Copiar `data/` en caliente puede dar restores corruptos → `scripts/mysql-dump.sh`
  (cron 2:30): `mysqldump --single-transaction` → `.sql.gz` verificado (gzip +
  tamaño mínimo) en `dumps/`, retención 7 días, alarma ntfy solo si falla.
- Backrest (3:00, ambos planes) excluye `stacks/mysql/data` y respalda `dumps/`.
  El histórico largo lo lleva restic (local + B2).

## Batallitas del estreno

- El primer run coincidió con una **caída global de GitHub Actions** (workflows
  en cola eternos, runs que ni se creaban). Lección: el pipeline depende de la
  salud de GitHub; el servicio no — el bot siguió online.
- Un commit vacío (`--allow-empty`) **no dispara** workflows con
  `paths-ignore`: sin archivos que evaluar, GitHub ni crea el run. El redisparo
  útil fue un cambio real: retirar `keep-alive.yml` (pingaba un servicio de
  Render que nunca existió).

## Pendientes

- `actions/setup-java@v5` en `ci.yml` (aviso de obsolescencia).
- App de Discord separada para test (SPEC: test ≠ prod).
- Cuenta de servicio de la API específica para prod (F3).
