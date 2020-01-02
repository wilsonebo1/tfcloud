<a name="backup-elasticsearch"></a>
# Backup Elasticsearch
----------------------
The following steps can be used to backup any Elasticsearch cluster, whether you are going to or from a single node or HA configuration. When backing up an HA Elasticsearch cluster, you must first enable elasticsearch backups, configure an NFS server, and configure NFS clients as described in the Installation and Configuration Guide.

Make sure that the Elasticsearch repository exists. The output is info about the registered repository.
```bash
curl -X GET "localhost:9200/_snapshot/DR_ES?pretty"
```

<a name="backup-elasticsearch-quickstart-docker"></a>
## Backup Elasticsearch Quickstart for Docker Installs
------------------------------------------------------
Start the Elasticsearch container on all nodes configured to run `elasticsearch`:
```bash
docker start elasticsearch
```

On any node configured to run `elasticsearch`, backup the elasticsearch cluster:
```bash
docker exec --user user -it elasticsearch sbin/datarobot-manage-elasticsearch backup
# this is a successful output:
<time-stamp> - tools.manager.elasticsearch - INFO - Creating "/opt/datarobot-runtime/data/elasticsearch/backup/snapshot-<timestamp>.tar.gz"
# the backup directory is mounted to "/opt/datarobot/data/elasticsearch/backup/" on the host
```

Stop the `elasticsearch` containers on each host configured to run `elasticsearch`:
```bash
docker stop elasticsearch
```

Move the backup to the `backups` directory:
```bash
mkdir -p /opt/datarobot/data/backups/elasticsearch
mv /opt/datarobot/data/backup/elasticsearch/snapshot-<timestamp>.tar.gz \
	/opt/datarobot/data/backups/elasticsearch/datarobot-elasticsearch-backup-$(date +%F).tar.gz
```

<a name="backup-elasticsearch-quickstart-rpm"></a>
## Backup Elasticsearch Quickstart for RPM Installs
---------------------------------------------------
As a user with sudo privileges, or as the root user, start the `datarobot-elasticsearch` service on all nodes configured to run `elasticsearch`:

CentOS 6 or RHEL 6
```bash
sudo service datarobot-elasticsearch start
```

CentOS 7 or RHEL 7
```bash
sudo systemctl start datarobot-elasticsearch
```

On any node configured to run `elasticsearch`, backup the elasticsearch cluster:
```bash
/opt/datarobot/DataRobot/sbin/datarobot-manage-elasticsearch backup
# this is a successful output:
<time-stamp> - tools.manager.elasticsearch - INFO - Creating "/opt/datarobot-runtime/data/elasticsearch/backup/snapshot-<timestamp>.tar.gz"
# the backup directory is mounted to "/opt/datarobot/data/elasticsearch/backup/" on the host
```

Stop the `datarobot-elasticsearch` service on each host configured to run the `elasticsearch` service:

CentOS 6 or RHEL 6
```bash
sudo service datarobot-elasticsearch stop
```

CentOS 7 or RHEL 7
```bash
sudo systemctl stop datarobot-elasticsearch
```

Move the backup to the `backups` directory:
```bash
mkdir -p /opt/datarobot/data/backups/elasticsearch
mv /opt/datarobot-runtime/data/elasticsearch/backup/snapshot-<timestamp>.tar.gz \
	/opt/datarobot/data/backups/elasticsearch/datarobot-elasticsearch-backup-$(date +%F).tar.gz
```


<a name="elasticsearch-api-reference"></a>
## List of API calls to make for verification/debugging purposes:
-----------------------------------------------------------------
```bash
# return info about the registered repository
curl -X GET "localhost:9200/_snapshot/DR_ES?pretty"
# check all snapshots in repo
curl -X GET "localhost:9200/_snapshot/DR_ES/_all?pretty"
# close all indices
curl -XPOST "localhost:9200/_all/_close"
# open all indices
curl -XPOST "localhost:9200/_all/_open"
# delete all indices
curl -XDELETE "localhost:9200/_all"
# return high level stats for all indices
curl -X GET "localhost:9200/_stats?pretty"
# return stats for an index
curl -X GET "localhost:9200/<index_name>/_stats?pretty"
# return setting info for an index
curl -X GET "localhost:9200/<index_name>/_settings?pretty"
# get cluster health status
curl -X GET "localhost:9200/_cluster/health?wait_for_status=yellow&timeout=50s&pretty"
```

<a name="elasticsearch-status-reports"></a>
## Understanding Elasticsearch status reports:
----------------------------------------------
Red: Some or all of (primary) shards are not ready.
Yellow: Elasticsearch has allocated all of the primary shards, but some/all of the replicas have not been allocated.
Green: Great. Your cluster is fully operational. Elasticsearch is able to allocate all shards and replicas to machines within the cluster.

<a name="elasticsearch-backup-restore-reference"></a>
## Elasticsearch Backup and Restore Reference Guide
---------------------------------------------------
<https://www.elastic.co/guide/en/elasticsearch/reference/6.4/modules-snapshots.html#_restoring_to_a_different_cluster>
