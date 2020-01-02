<a name="restore-elasticsearch"></a>
# Restore Elasticsearch
-----------------------
The following steps can be used to restore any Elasticsearch cluster, whether you are goint to or from a single node or HA configuration.  When restore an HA Elasticsearch cluster, you must first enable elasticsearch backups, configure an NFS server, and configure NFS clients as described in the Installation and Configuration Guide.

<a name="restore-elasticsearch-quickstart-docker"></a>
## Restore Elasticsearch Quickstart for Docker Installs
-------------------------------------------------------
Extract the backup archive on any single node configured to run the `elasticsearch` service:
```bash
cd /opt/datarobot/backup/
tar -xf /opt/datarobot/backups/elasticsearch/datarobot-elasticsearch-backup-<backup_date>.tar.gz
```

Start the Elasticsearch container on all nodes configured to run `elasticsearch`:
```bash
docker start elasticsearch
```

Restore the Elasticsearch cluster from the node previously selected to extract the backup archive:
```bash
docker exec -it elasticsearch sbin/datarobot-manage-elasticsearch restore
```

Validate that the Elasticsearch indexes were restored:
```bash
curl -X GET "localhost:9200/_cat/indices?v&pretty" # checks for all indices
curl -X GET "localhost:9200/catalog/_search?q=*&pretty" # checks the catalog index for everything
```

Stop the `elasticsearch` containers on every node configured to run `elasticsearh`:
```bash
docker stop elasticsearch
```

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

## Understanding Elasticsearch status reports:
----------------------------------------------
Red: Some or all of (primary) shards are not ready.
Yellow: Elasticsearch has allocated all of the primary shards, but some/all of the replicas have not been allocated.
Green: Great. Your cluster is fully operational. Elasticsearch is able to allocate all shards and replicas to machines within the cluster.

## Reference
------------
<https://www.elastic.co/guide/en/elasticsearch/reference/6.4/modules-snapshots.html#_restoring_to_a_different_cluster>
