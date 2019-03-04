# Mongo WiredTiger Internal Cache Configuration

Lowering the WiredTiger internal cache size value is recommended to prevent memory overconsumption in installs with limited memory.

### Background on WiredTiger Internal Cache Mechanism

With DataRobot version 4.2+, the mongo version is 3.4 which uses a backend mongo storage engine called WiredTiger. WiredTiger's internal cache size is set by default to be either:
* 50% of (RAM - 1 GB), or
* 256 MB.

A more detailed background on WiredTiger Internal Cache Mechanism can be found
[here](https://docs.mongodb.com/manual/faq/storage/#to-what-size-should-i-set-the-wiredtiger-internal-cache)

## Limiting WiredTiger Memory

The maximum cache size allocation can be queried by the datarobot user:

```bash
source /opt/datarobot/etc/profile
mongo --eval "db.serverStatus().wiredTiger.cache['maximum bytes configured']"
```

In order to adjust the size of the WiredTiger internal cache, modify the `mongod.conf` template and reconfigure mongo:

1. Edit `ansible/roles/mongo/templates/mongod.conf.j2` to include the following _under_ the `storage` section (example limits to 1 GB):

```yaml
  wiredTiger.engineConfig.cacheSizeGB: 1
```

2. Reconfigure services

```yaml
bin/datarobot install --pre-configure
bin/datarobot services restart
```

3. Confirm that the running mongo container has WiredTiger using the specified cache size:

```bash
source /opt/datarobot/etc/profile
mongo --eval "db.serverStatus().wiredTiger.cache['maximum bytes configured']"
```
