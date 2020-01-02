<a name="consolidate-backups"></a>
# Consolidate Backups
---------------------

Once you have finished executing all of the appropriate backups for your installation you may have backup archives distributed between multiple systems, depending on your configuration. After backups are complete, and the DataRobot Instance has been returned to service, you should consolidate your backups to a single location.  The following is a complete list of backup archives described in this document:

Gluster: `/opt/datarobot/data/backups/gluster/datarobot-gluster-backup-<date>.tar`
MinIO: `/opt/datarobot/data/backups/minio/datarobot-minio-backup-<date>.tar`
Redis: `/opt/datarobot/data/backups/redis/dump.rdb`
MongoDB: `/opt/datarobot/data/backups/mongo/datarobot-monogo-backup-<date>.tar`
PostgreSQL: `/opt/datarobot/data/backups/pgsql/datarobot-pgsql-backup-<date>.tar`
Patroni: `/opt/datarobot/data/backups/patroni/datarobot-patroni-backup-<date>.tar`
Elasticsearch: `/opt/datarobot/data/backups/elasticsearch/datarobot-elasticsearch-backup-<date>.tar.gz`


Not all of these files are appropriate for every DataRobot installation, but ensure that each of the defined services included in your configuration are backed up on a regular basis.

Tools that can be used to centralize backup archives include, but are not limited to, `scp`, `rsync`, or `nfs`.  Choose the tool that is appropriate for your environment.
