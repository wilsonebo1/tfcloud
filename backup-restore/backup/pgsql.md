<a name="backup-pgsql"></a>
# Backup PostgreSQL
-------------------

<a name="backup-pgsql-quickstart-docker"></a>
## Backup PostgreSQL Quickstart for Docker Installs
---------------------------------------------------
Start the PostgreSQL container on the data node configured to run `pgsql`:
```bash
docker start pgsql
```

Backup the PostgreSQL database on the same data node:
```bash
mkdir -p /opt/datarobot/data/backups/pgsql
docker run --network host --rm -it -u $(id -u) \
    -v /opt/datarobot/data/backups/pgsql:/opt/datarobot/data/backups/pgsql \
    $(docker images | grep -m1 datarobot-runtime | awk '{print $1":"$2}') \
    python -m tools.manager.pgsql create-backup \
    --backup-location=/opt/datarobot/data/backups/pgsql/
```

Stop the `pgsql` container:
```bash
docker stop pgsql
```

Create a tar archive to consolidate the backup:
```bash
tar -cf /opt/datarobot/data/backups/pgsql/datarobot-pgsql-backup-$(date +%F).tar \
    --remove-files /opt/datarobot/data/backups/pgsql/*
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
tar -cf /opt/datarobot/data/backups/pgsql/datarobot-pgsql-backup-$(date +%F).tar \
    --remove-files /opt/datarobot/data/backups/pgsql/*
```
