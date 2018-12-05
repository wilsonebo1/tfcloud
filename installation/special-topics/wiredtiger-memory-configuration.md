# Mongo WiredTiger Internal Cache Configuration

### In Installs with Limited Memory
Lowering the WiredTiger internal cache size value is recommended to prevent memory overconsumption.

### Background on WiredTiger Internal Cache Mechanism
With DataRobot version 4.2+, the mongo version is 3.4 which uses a backend mongo storage engine called WiredTiger. WiredTiger's internal cache size is set by default to be either:
* 50% of (RAM - 1 GB), or
* 256 MB.

A more detailed background on WiredTiger Internal Cache Mechanism can be found
[here](https://docs.mongodb.com/manual/faq/storage/#to-what-size-should-i-set-the-wiredtiger-internal-cache)

## Docker Installs

To view the maximum cache size allocated:
```bash
docker exec -it mongo mongo --eval "db.serverStatus().wiredTiger.cache['maximum bytes configured']"
```

In order to adjust the size of the WiredTiger internal cache:
1. Create a '/opt/datarobot/etc/mongod.conf' with the following text:
```bash
dbpath=/data/db
logappend=true
pidfilepath=/data/db/mongod.pid
nojournal = false
noprealloc = true
wiredTigerCacheSizeGB = 1 # set this to a value depending on the amount of memory on the host
```

2. In the installer directory, edit release/docker-compose-baked.yml. Find the mongo container and under volumes add an additional volume to mount in this new config file:
```yaml
- "etc/mongod.conf:/opt/datarobot/etc/mongod.conf:z"
```

3. Run: 
```bash
./bin/datarobot reconfigure
```

4. Confirm that the running mongo container has WiredTiger using the specified cache size:
```bash
docker exec -it mongo mongo --eval "db.serverStatus().wiredTiger.cache['maximum bytes configured']"
```
