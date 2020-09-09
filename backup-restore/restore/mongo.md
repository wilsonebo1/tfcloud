<a name="restoring-mongo"></a>
# Restoring Mongo
-----------------

<a name="restore-mongo-quickstart-docker"></a>
## Restore Mongo Quickstart for Docker Installs
-----------------------------------------------
Extract the tar archive of the backed-up database files:
```bash
mkdir -p /opt/datarobot/data/mongo
cd /opt/datarobot/data/mongo
tar -xf /opt/datarobot/data/backups/mongo/datarobot-mongo-backup-<backup_date>.tar
```

Start the Mongo container on every data node configured to run `mongo`:
```bash
docker start mongo
```

Restore the Mongo database on any single `mongo` data node:
```bash
docker exec -it mongo /entrypoint sbin/datarobot-manage-mongo restore --backup-dir /opt/datarobot-runtime/data/mongo/backup
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

Start the DataRobot Mongo database service on all data nodes configured to run `mongo`:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl start mongo
```

Restore the Mongo database on any single `mongo` data node:
```bash
/opt/datarobot/app/DataRobot/sbin/datarobot-manage-mongo restore --backup-dir /opt/datarobot-runtime/data/mongo/backup
```

Stop the `datarobot-mongo` service:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl stop mongo
```
