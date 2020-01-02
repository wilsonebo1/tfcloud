<a name="backup-redis"></a>
# Backup Redis
--------------

<a name="backup-redis-quickstart-docker"></a>
## Backup Redis Quickstart For Docker Installs
----------------------------------------------
On a node configured to run Redis, copy the Redis `dump.rdb` backup into the datarobot backups directory:

```bash
mkdir -p /opt/datarobot/data/backups/redis
cp /opt/datarobot/data/redis/dump.rdb /opt/datarobot/data/backups/redis/datarobot-redis-backup-$(date +%F).rdb
```

<a name="backup-redis-quickstart-rpm"></a>
## Backup Redis Quickstart for RPM Installs
-------------------------------------------
On a node configured to run Redis, copy the Redis `dump.rdb` backup into the datarobot backups directory:

```bash
mkdir -p /opt/datarobot/data/backups/redis
cp /opt/datarobot/data/dump.rdb /opt/datarobot/data/backups/redis/datarobot-redis-backup-$(date +%F).rdb
```
