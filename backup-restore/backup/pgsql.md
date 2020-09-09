<a name="backup-pgsql"></a>
# Backup PostgreSQL
-------------------

<a name="backup-pgsql-quickstart-docker"></a>
## Backup PostgreSQL Quickstart for Docker Installs
---------------------------------------------------
Start the PostgreSQL container and create the backup directory on the data node configured to run `pgsql`:
```bash
docker start pgsql
mkdir -p /opt/datarobot/data/pgsql/backup
```

Backup the PostgreSQL databases on the same data node:
```bash
docker exec -it pgsql /entrypoint python -m tools.manager.pgsql create-backup \
    --backup-location /opt/datarobot-runtime/data/postgresql/backup/
```

Stop the `pgsql` container:
```bash
docker stop pgsql
```

Create a tar archive to consolidate the backup:
```bash
mkdir -p /opt/datarobot/data/backups/pgsql
cd /opt/datarobot/data/pgsql/
tar -cf /opt/datarobot/data/backups/pgsql/datarobot-pgsql-backup-$(date +%F).tar --remove-files backup
```

<a name="backup-pgsql-quickstart-rpm"></a>
## Backup PostgreSQL Quickstart for RPM Installs
------------------------------------------------
Start the DataRobot PostgreSQL database service on the data node configured to run `pgsql`:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl start postgres
```

Backup the PostgreSQL data node running `pgsql`:
```bash
mkdir -p /opt/datarobot/data/backups/pgsql
source /opt/datarobot/etc/profile
python -m tools.manager.pgsql create-backup \
    --backup-location=/opt/datarobot/data/backups/pgsql/
```

Stop the DataRobot PostgreSQL database service on the data node configured to run `pgsql`:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl stop postgres
```

Create a tar archive to consolidate the backup:
```bash
cd /opt/datarobot/data/backups
tar -cf /opt/datarobot/data/backups/pgsql/datarobot-pgsql-backup-$(date +%F).tar \
    --remove-files pgsql
```
