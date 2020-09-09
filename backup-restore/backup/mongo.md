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
docker exec -it mongo /entrypoint sbin/datarobot-manage-mongo backup --backup-dir /opt/datarobot-runtime/data/mongo/backup
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
Start the DataRobot Mongo database service on a data node configured to run `mongo`:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl start mongo
```

Backup the Mongo database on the same data node:
```bash
/opt/datarobot/app/DataRobot/sbin/datarobot-manage-mongo backup --backup-dir /opt/datarobot/data/mongo/backup
```

Stop the `datarobot-mongo` service:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl stop mongo
```

Create a tar archive of the backed-up database files and delete the backup files after they are archived:
```bash
mkdir -p /opt/datarobot/data/backups/mongo
cd /opt/datarobot/data/mongo
tar -cf /opt/datarobot/data/backups/mongo/datarobot-mongo-backup-$(date +%F).tar --remove-files backup
```
