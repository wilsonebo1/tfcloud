<a name="restore-patroni"></a>
# Restore Patroni
-----------------

<a name="restore-patroni-quickstart-docker"></a>
## Restore Patroni Quickstart for Docker Installs
-------------------------------------------------
Extract the backup archive on any one node configured to run the `patroni` service:
```bash
mkdir -p /opt/datarobot/data/patroni/backup
cd /opt/datarobot/data/patroni/backup
tar -xf /opt/datarobot/data/backups/pgsql/datarobot-pgsql-backup-<backup_date>.tar
```

Start the Zookeeper service on every node configured to run the `zookeeper` service:
```bash
docker start zookeeper
```

Start the Patroni service on every data node configured to run the `patroni` service:
```bash
docker start patroni
```

Restore the Patroni database on the node where the backup archive was previously extracted:
```bash
docker exec -it patroni /entrypoint \
    python -m tools.manager.pgsql configure \
    --backup-location=/opt/datarobot-runtime/data/patroni/backup/
```

Stop the Patroni service on every data node configured to run the `patroni` service:
```bash
docker stop patroni
```

Stop the Zookeeper service on every node configured to run the `zookeeper` service:
```bash
docker stop zookeeper
```

<a name="restore-patroni-quickstart-rpm"></a>
## Restore PostgreSQL Quickstart for RPM Installs
-------------------------------------------------
Extract the backup archive on any one node configure to run the `patroni` service:
```bash
cd /opt/datarobot/data/backups/pgsql
tar -xf datarobot-pgsql-backup-<backup_date>.tar
```

Start the DataRobot Zookeeper service on all of the nodes configured to run `zookeeper`:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl start zookeeper
```

Start the DataRobot Patroni database service on all of the data nodes configured to run `patroni`:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl start patroni
```

Restore the PostgreSQL database on the node previously selected to extract the backup archive:
```bash
source /opt/datarobot/etc/profile
python -m tools.manager.pgsql configure \
    --backup-location=/opt/datarobot/data/backups/pgsql/
```

Stop the DataRobot PostgreSQL database service on the data node configured to run `patroni`:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl stop patroni
```

Stop the DataRobot Zookeeper service on all of the nodes configured to run `zookeeper`:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl stop zookeeper
```

