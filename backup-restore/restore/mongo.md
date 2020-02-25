<a name="restoring-mongo"></a>
# Restoring Mongo
-----------------

<a name="restore-mongo-quickstart-docker"></a>
## Restore Mongo Quickstart for Docker Installs
-----------------------------------------------
Extract the tar archive of the backed-up database files:
```bash
mkdir -p /opt/datarobot/data/mongo
tar -xf /opt/datarobot/data/backups/mongo/datarobot-mongo-backup-<backup_date>.tar
```

Start the Mongo container on every data node configured to run `mongo`:
```bash
docker start mongo
```

Restore the Mongo database on any single `mongo` data node:
```bash
docker exec -u user -it mongo sbin/datarobot-manage-mongo restore \
    --backup-dir /opt/datarobot-runtime/data/mongo/backup
```

Stop the `mongo` container on every data node configured to run `mongo`:
```bash
docker stop mongo
```

<a name="restore-mongo-quickstart-rpm"></a>
## Restore Mongo Quickstart for RPM Installs
--------------------------------------------
Extract the tar archive of the backed-up database files:
```bash
mkdir -p /opt/datarobot/data/mongo
tar -xf /opt/datarobot/data/backups/mongo/datarobot-mongo-backup-<backup_date>.tar
```

As a user with sudo privileges, or as the root user, start the DataRobot Mongo database service on all data nodes configured to run `mongo`:

CentOS 6 or RHEL 6
```bash
sudo service datarobot-mongo start
```

CentOS 7 or RHEL 7
```bash
sudo systemctl start datarobot-mongo
```

Restore the Mongo database on any single `mongo` data node:
```bash
/opt/datarobot/app/DataRobot/sbin/datarobot-manage-mongo restore \
    --backup-dir /opt/datarobot-runtime/data/mongo/backup
```

As a user with sudo privileges, or as the root user, stop the `datarobot-mongo` service:

CentOS 6 or RHEL 6
```bash
sudo service datarobot-mongo stop
```

CentOS 7 or RHEL 7
```bash
sudo systemctl stop datarobot-mongo
```
