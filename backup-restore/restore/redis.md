<a name="restore-redis"></a>
# Restore Redis
---------------

<a name="restore-redis-quickstart-docker"></a>
## Restore Redis Quickstart for Docker Installs
-----------------------------------------------
On a node configured to run Redis, copy the Redis `dump.rdb` backup into the Redis data directory:

```bash
cp /opt/datarobot/data/backups/redis/datarobot-redis-backup-$(date +%F).rdb /opt/datarobot/data/redis/dump.rdb
```

<a name="restore-redis-quickstart-rpm"></a>
## Restore Redis Quickstart for RPM Installs
--------------------------------------------
On a node configured to run Redis, copy the Redis `dump.rdb` backup into the Redis data directory:

```bash
cp /opt/datarobot/data/backups/redis/datarobot-redis-backup-$(date +%F).rdb /opt/datarobot/data/dump.rdb
```
