<a name="backup-patroni"></a>
# Backup Patroni
----------------

<a name="backup-patroni-quickstart-docker"></a>
## Backup Patroni Quickstart for Docker Installs
------------------------------------------------
Start the Zookeeper service on every node configured to run the `zookeeper` service:
```bash
docker start zookeeper
```

Start the Patroni service on every data node configured to run the `patroni` service:
```bash
docker start patroni
```

Backup the Patroni database on one of the `patroni` nodes:
```bash
mkdir /opt/datarobot/data/patroni/backup
docker exec -it patroni /entrypoint \
    python -m tools.manager.pgsql create-backup \
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

Create a tar archive to consolidate the backup:
```bash
tar -cf /opt/datarobot/data/backups/pgsql/datarobot-pgsql-backup-$(date +%F).tar \
    --remove-files /opt/datarobot/data/patroni/backup
```

<a name="backup-patroni-quickstart-rpm"></a>
## Backup PostgreSQL Quickstart for RPM Installs
------------------------------------------------
Start the DataRobot Zookeeper service on all of the nodes configured to run `zookeeper`:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl start zookeeper
```

Start the DataRobot Patroni database service on all of the data nodes configured to run `patroni`:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl start patroni
```

Backup the PostgreSQL data node running `postgres`:
```bash
mkdir -p /opt/datarobot/data/backups/pgsql
source /opt/datarobot/etc/profile
python -m tools.manager.pgsql create-backup \
    --backup-location=/opt/datarobot/data/backups/pgsql/
```

Stop the DataRobot Patroni database service on all of the data nodes configured to run `patroni`:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl stop patroni
```

Stop the DataRobot Zookeeper service on all of the nodes configured to run `zookeeper`:

```bash
/opt/datarobot/sbin/datarobot-supervisorctl stop zookeeper
```

Create a tar archive to consolidate the backup:
```bash
tar -cf /opt/datarobot/data/backups/pgsql/datarobot-pgsql-backup-$(date +%F).tar \
    --remove-files /opt/datarobot/data/backups/pgsql/*
```
