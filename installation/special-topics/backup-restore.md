# Backup Restore

DataRobot supports backup and restore for elasticsearch.

## Elasticsearch

Scenario backing up old host machine to a new host
1. On host machine being backed up:
```bash
docker exec -it elasticsearch /bin/bash
sbin/datarobot-manage-elasticsearch backup
# this is a successful output:
<time-stamp> - tools.manager.elasticsearch - INFO - Creating "/opt/datarobot-runtime/data/elasticsearch/backup/snapshot-<timestamp>.tar.gz"
# the backup directory is mounted to "/opt/datarobot/data/elasticsearch/backup/" on the host
```
2. scp the tar.gz file over to new host machine
3. On new host machine, untar the snapshot-<timestamp>.tar.gz file into the backup directory at "/opt/datarobot/data/elasticsearch/backup/"
```bash
tar -zxf snapshot-<timestamp>.tar.gz
```
4. Stop mongoconnector and availabilitymonitor
```bash
docker stop mongoconnector
docker stop availabilitymonitor
```
5. Call restore CLI
```bash
docker exec -it elasticsearch /bin/bash
sbin/datarobot-manage-elasticsearch restore
```
6. Check that the indices were transferred over
```bash
curl -X GET "localhost:9200/_cat/indices?v&pretty" # checks for all indices
curl -X GET "localhost:9200/catalog/_search?q=*&pretty" # checks the catalog index for everything
```
7. Start mongoconnector and availabilitymonitor
```bash
docker start mongoconnector
docker start availabilitymonitor
```

Curl commands:
```bash
curl -X GET "localhost:9200/_snapshot/DR_ES/_all?pretty" # check all snapshots in repo
curl -XPOST "localhost:9200/_all/_close" # close all indices
curl -XPOST "localhost:9200/_all/_open" # open all indices
curl -XDELETE “localhost:9200/_all" # delete all indices
```
