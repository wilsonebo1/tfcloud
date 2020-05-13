<a name="restore-pgsql"></a>
# Restore PostgreSQL
--------------------

<a name="restore-pgsql-quickstart-docker"></a>
## Restore PostgreSQL Quickstart for Docker Installs
----------------------------------------------------
Extract the backup archive on the data node configured to run `pgsql`:
```bash
cd /opt/datarobot/data/pgsql
tar -xf /opt/datarobot/data/backups/pgsql/datarobot-pgsql-backup-<backup_date>.tar
```

Start the PostgreSQL container on the data node configured to run `pgsql`:
```bash
docker start pgsql
```

Restore the PostgreSQL database on the same data node:
```bash
docker exec -it -u $(id -u) pgsql python -m tools.manager.pgsql configure --backup-location /opt/datarobot-runtime/data/postgresql/backup/
```

Stop the `pgsql` container:
```bash
docker stop pgsql
```

<a name="restore-pgsql-quickstart-rpm"></a>
## Restore PostgreSQL Quickstart for RPM Installs
-------------------------------------------------
Extract the backup archive on the data node configured to run `pgsql`:
```bash
cd /opt/datarobot/data/pgsql
tar -xf /opt/datarobot/data/backups/pgsql/datarobot-pgsql-backup-<backup_date>.tar
```

As a user with sudo privileges, or as the root user, start the DataRobot PostgreSQL database service on the data node configured to run `pgsql`:

CentOS 6 or RHEL 6
```bash
sudo service datarobot-postgres start
```

CentOS 7 or RHEL 7
```bash
sudo systemctl start datarobot-postgres
```

Restore the PostgreSQL datanode running `pgsql`:
```bash
source /opt/datarobot/etc/profile
python -m tools.manager.pgsql configure \
    --backup-location=/opt/datarobot/data/pgsql/backup/
```

AS a user with sudo privileges, or as the root user, stop the DataRobot PostgreSQL database service on the data node configured to run `pgsql`:

CentOS 6 or RHEL 6
```bash
sudo service datarobot-postgres stop
```

CentOS 7 or RHEL 7
```bash
sudo systemctl stop datarobot-postgres
```
