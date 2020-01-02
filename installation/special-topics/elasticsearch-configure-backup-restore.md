# Backup and Restore

DataRobot supports backup and restore of indices for elasticsearch.

## Snapshot, Repository, Restore, Defaults

### Snapshot
A snapshot is a backup taken from a running Elasticsearch cluster. You can take a snapshot of an entire cluster and store it in a repository on a shared filesystem and there's plugins that can support remote repositories on S3, HDFS, Azure, and Google Cloud Storage.

Snapshots are taken incrementally. This means that when creating a snapshot of an index Elasticsearch will avoid copying any data that is already stored in the repository as part of an earlier snapshot of the same index. Therefore it can be efficient to take snapshots of your cluster quite frequently.

### Repository
Before performing a snapshot and restore, a snapshot repository must be registered. A repository can contain multiple snapshots of the same cluster.

### Restore
Given a snapshot, the indices in the snapshot can be restored to a functioning cluster. It is possible to restore a snapshot made from one cluster to another cluster and the new cluster doesn't have to have the same size or topology. However, the version of the new cluster should be the same or newer (only 1 major version of elasticsearch newer) than the cluster that was used to create the snapshot.

### DataRobot Snapshot/Repository Defaults
DataRobot default snapshot file are named `"snapshot-<timestamp>.tar.gz"` with the timestamp of when the snapshot was taken when running the `"backup cli"`.
DataRobot Default repository settings define `("type": "fs")` using the shared file system to store snapshots in the `"location"`.
```bash
{
  "DR_ES" : {
    "type" : "fs",
    "settings" : {
      "compress" : "true",
      "location" : "/opt/datarobot-runtime/data/backup/elasticsearch"
    }
  }
}
```
The Backup and Restore Guide provides instructions for creating a snapshot thru the `Backup CLI` and restoring a snapshot thru the `Restore CLI`.

## Enable Backup/Restore Functionality
1. Add this to config.yaml
```bash
os_configuration:
  elasticsearch:
    enable_local_backup: true
```
2. Run the dependency installation command.
```bash
./bin/datarobot setup-dependencies
```
3. Configure and run services that make up DataRobot application.
```bash
./bin/datarobot install
```

## Requirements for backup/restore
In order to perform snapshot and restore operations, you need a repository with a shared filesystem defined storing snapshots at a backup location which can be shared across multiple hosts. If the topology is a multinode elasticsearch, NFS can be used to share the backup location across multiple hosts.

### Setting up NFS
1. Install NFS server on one of the nodes (to be the NFS server host).
2. Install NFS common for the rest of the node(s) (to be the NFS client host(s)).
Here we describe an NFS topology with the backup directory `$DATAROBOT_HOME/data/backup` mounted on each elasticsearch host as a NFS share with NFS options: `rw,sync,no_root_squash`. We recommend setting up NFS for backups prior to an installation or upgrade.

### Configuring NFS to share backup directory
1. On the NFS server host, in `/etc/exports`, make sure the data directory is shared across the hosts.
```bash
$DATAROBOT_HOME/data/backup <network-number>.0.0/16(rw,sync,no_root_squash)
```
2. On the NFS server host, export the directory.
```bash
sudo exportfs -av
```
3. On the NFS server host, restart NFS.
```bash
sudo systemctl restart nfs
```
4. On the NFS server host, check that directory is in table of exported NFS file systems.
```bash
sudo exportfs
```
5. On the NFS clients, add an entry in `/etc/fstab` for the NFS share:
```bash
<NFS server>:<datarobot home>/data/backup <datarobot_home>/data/backup nfs auto,rw,noatime,nolock,bg,nfsvers=4,tcp 0 0
```
6. On the NFS clients, remount the directory.
```bash
sudo umount $DATAROBOT_HOME/data/backup
sudo mount $DATAROBOT_HOME/data/backup
```

Now proceed with installation/upgrade. If there was a pre-existing installation, then you will need to re-install to get backups working.

7. Terminate all docker containers on all hosts:
```bash
sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)
```
8. Start docker registry
```bash
./bin/datarobot run-registry
```
9. Start docker containers
```bash
./bin/datarobot install
```
