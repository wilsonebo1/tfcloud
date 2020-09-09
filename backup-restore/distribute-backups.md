<a name="distribute-backups"></a>
# Distribute Backup Archives
----------------------------

Before performing a restore of the DataRobot environment, you will have to distribute the backup archives to nodes configured to run the specified services.  In some configurations they may all run on the same hosts, but some configurations may run different services on different nodes.

In HA environments, only one node will require the archive; all nodes in the HA configuration will need to be active during restore activities, but only one node will perform the restore.

The following is a complete list of backup archives described in this document:

Gluster: `/opt/datarobot/data/backups/gluster/datarobot-gluster-backup-<date>.tar`
MinIO: `/opt/datarobot/data/backups/minio/datarobot-minio-backup-<date>.tar`
Redis: `/opt/datarobot/data/backups/redis/dump.rdb`
MongoDB: `/opt/datarobot/data/backups/mongo/datarobot-monogo-backup-<date>.tar`
PostgreSQL: `/opt/datarobot/data/backups/pgsql/datarobot-pgsql-backup-<date>.tar`
Patroni: `/opt/datarobot/data/backups/patroni/datarobot-patroni-backup-<date>.tar`

Not all of these files are appropriate for every DataRobot installation, but ensure that each of the defined services included in your configuration are backed up on a regular basis.

Tools that can be used to distribute backup archives include, but are not limited to, `scp`, `rsync`, or `nfs`.  Choose the tool that is appropriate for your environment.
