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
docker exec -u user -it patroni \
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

As a user with sudo privileges, or as the root user, start the DataRobot Zookeeper service on all of the nodes configured to run `zookeeper`:

CentOS 6 or RHEL 6
```bash
sudo service datarobot-zookeeper start
```

CentOS 7 or RHEL 7
```bash
sudo systemctl start datarobot-zookeeper
```

As a user with sudo privileges, or as the root user, start the DataRobot Patroni database service on all of the data nodes configured to run `patroni`:

CentOS 6 or RHEL 6
```bash
sudo service datarobot-patroni start
```

CentOS 7 or RHEL 7
```bash
sudo systemctl start datarobot-patroni
```

Restore the PostgreSQL database on the node previously selected to extract the backup archive:
```bash
source /opt/datarobot/etc/profile
python -m tools.manager.pgsql configure \
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

As a user with sudo privileges, or as the root user, stop the DataRobot Zookeeper service on all of the nodes configured to run `zookeeper`:

CentOS 6 or RHEL 6
```bash
sudo service datarobot-zookeeper stop
```

CentOS 7 or RHEL 7
```bash
sudo systemctl stop datarobot-zookeeper
```
