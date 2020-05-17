<a name="backup-minio"></a>
# Backup MinIO
--------------

**NOTE**: MinIO is only supported in docker-based installations.

<a name="backup-minio-quickstart"></a>
## Backup MinIO Quickstart
--------------------------
Start the MinIO dockers on all of the data nodes by running the following command on all data backend nodes:
```bash
docker start minio
```

Backup the MinIO cluster on any one of the data backend nodes with the following commands:
```bash
mkdir -p /opt/datarobot/data/minio/backup
docker exec -u user -it minio bash
source <(python2 -m config.render -g minio -T "{{minio_env | shexports}}")
mc config host add minio https://${MINIO_HOST}:${MINIO_PORT} ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY} --api S3v4
# should result in 'Added `minio` successfully.'
mc cp --insecure -r minio/${MINIO_BUCKET}/ /opt/datarobot-runtime/data/backup
exit

```

Create a tar archive of the backed-up MinIO files:
```bash
mkdir -p /opt/datarobot/data/backups/minio
cd /opt/datarobot/data/minio
tar -czf /opt/datarobot/data/backups/minio/datarobot-minio-backup-$(date +%F).tar.gz --remove-files ./backup
```

Stop the MinIO dockers on all of the data nodes by running the following command on all data backend nodes:
```bash
docker stop minio
```

<a name="backing-up-minio"></a>
## Backing Up MinIO
-------------------
**NOTE**: Backing up a large dataset can take a significant amount of time, so it is recommended that a terminal multiplexer (e.g. `tmux` or `screen`) is used to manage this backup.  This will prevent accidental disconnection from interrupting a backup and allow you to check the status of the backup.

You will need a directory large enough to accommodate a backup of the MinIO datastore. The instructions provided will create a backup at `/opt/datarobot/data/minio/backups` and any additional disk or external filesystem should be mounted at that location.

All of the configured MinIO nodes should be running during the backup, however you only need to execute the backup against a single `minio` instance; the backup command will backup the entire MinIO bucket.  Any `minio` instance is acceptable for this backup activity.

On every node configured to host a `minio` docker, start the `minio` instance:
```bash
docker start minio
```

Backing up MinIO should occur on an instance with MinIO already running on it. `docker ps | grep minio` should return a running `minio` docker container.

If it doesn't exist, first create the minio backup directory:
```bash
mkdir /opt/datarobot/data/minio/backups
```

Enter the running MinIO docker:
```bash
docker exec -it minio bash
```

Set the required MinIO variables:
```bash
source <(python2 -m config.render -g minio -T "{{minio_env | shexports}}")
```

Create an alias for the local minio instance:
```bash
mc config host add minio https://${MINIO_HOST}:${MINIO_PORT} ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY} --api S3v4
```

Copy the data from the MinIO bucket to the MinIO backup directory:
```bash
mc cp --insecure -r minio/${MINIO_BUCKET}/ /opt/datarobot-runtime/data/backup
```

**NOTE**: The `--insecure` flag is used in this instance because the `minio` SSL certifiate authenticates against the host IP address, not 127.0.0.1. Data is still encrypted in transit, but the Certificate Authority is not validated during a localhost copy.

**NOTE**: While MinIO encrypts data at rest inside the MinIO bucket, copying the data out of the bucket will decrypt the data.  Backups created using this mechanism will not be encrypted at rest. Use your corporate data management policies to ensure that this data is protected appropriately.

Exit the running MinIO docker:
```bash
exit
```

Create a tar archive of the backed-up MinIO files and remove the backed-up files after they have been archived:
```bash
mkdir -p /opt/datarobot/data/backups/minio
cd /opt/datarobot/data/minio/backup
tar -cf /opt/datarobot/data/backups/minio/datarobot-minio-backup-$(date +%F).tar --remove-files ./*
```

On every node configured to host a `minio` docker, stop the `minio` instance:
```bash
docker stop minio
```
