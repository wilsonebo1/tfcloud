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
docker exec -it -u $(id -u) pgsql python -m tools.manager.pgsql create-backup \
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
As a user with sudo privileges, or as the root user, start the DataRobot PostgreSQL database service on the data node configured to run `pgsql`:

CentOS 6 or RHEL 6
```bash
sudo service datarobot-postgres start
```

CentOS 7 or RHEL 7
```bash
sudo systemctl start datarobot-postgres
```

Backup the PostgreSQL data node running `pgsql`:
```bash
mkdir -p /opt/datarobot/data/backups/pgsql
source /opt/datarobot/etc/profile
python -m tools.manager.pgsql create-backup \
    --backup-location=/opt/datarobot/data/backups/pgsql/
```

As a user with sudo privileges, or as the root user, stop the DataRobot PostgreSQL database service on the data node configured to run `pgsql`:

CentOS 6 or RHEL 6
```bash
sudo service datarobot-postgres stop
```

CentOS 7 or RHEL 7
```bash
sudo systemctl stop datarobot-postgres
```

Create a tar archive to consolidate the backup:
```bash
cd /opt/datarobot/data/backups
tar -cf /opt/datarobot/data/backups/pgsql/datarobot-pgsql-backup-$(date +%F).tar \
    --remove-files pgsql
```
