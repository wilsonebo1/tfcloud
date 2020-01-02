<a name="backup-mongo"></a>
# Backup Mongo

<a name="backup-mongo-quickstart-docker"></a>
## Backup Mongo Quickstart for Docker Installs
-------------------------------------------
Start the Mongo container on any data node configured to run `mongo`:
```bash
docker start mongo
```

Backup the Mongo database on the same data node:
```bash
docker exec -u user -it mongo sbin/datarobot-manage-mongo backup --backup-dir /opt/datarobot-runtime/data/mongo/backup
```

Stop the `mongo` container:
```bash
docker stop mongo
```

Create a tar archive of the backed-up database files and delete the backup files after they are archived:
```bash
mkdir -p /opt/datarobot/data/backups/mongo
cd /opt/datarobot/data/mongo
tar -cf /opt/datarobot/data/backups/mongo/datarobot-mongo-backup-$(date +%F).tar --remove-files backup
```

<a name="backup-mongo-quickstart-rpm"></a>
## Backup Mongo Quickstart for RPM Installs
----------------------------------------
As a user with sudo privileges, or as the root user, start the DataRobot Mongo database service on a data node configured to run `mongo`:

CentOS 6 or RHEL 6
```bash
sudo service datarobot-mongo start
```

CentOS 7 or RHEL 7
```bash
sudo systemctl start datarobot-mongo
```

Backup the Mongo database on the same data node:
```bash
/opt/datarobot/app/DataRobot/sbin/datarobot-manage-mongo backup --backup-dir /opt/datarobot/data/mongo/backup
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

Create a tar archive of the backed-up database files and delete the backup files after they are archived:
```bash
mkdir -p /opt/datarobot/data/backups/mongo
cd /opt/datarobot/data/mongo
tar -cf /opt/datarobot/data/backups/mongo/datarobot-mongo-backup-$(date +%F).tar --remove-files backup
```
