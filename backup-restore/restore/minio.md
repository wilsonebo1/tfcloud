<a name="restore-minio"></a>
# Restore MinIO
---------------

**NOTE**: MinIO is only supported in docker-based installations.

<a name="restore-minio-quickstart"></a>
## Restore MinIO Quickstart
---------------------------
Extract the backup archive on any one of the data backend nodes with the following commands:
```bash
mkdir -p /opt/datarobot/data/minio
cd /opt/datarobot/data/minio
tar -xvf /opt/datarobot/data/backups/minio/datarobot-minio-backup-<backup_date>.tar.gz
```

Start the MinIO dockers on all the data nodes by running the following command on all data backend nodes:
```bash
docker start minio
```

Restore the MinIO cluster on the data node where the backup archive was extracted:
```bash
docker exec -it minio /entrypoint bash
source <(python3 -m config.render -g minio -T "{{minio_env | shexports}}")
mc config host add minio https://${MINIO_HOST}:${MINIO_PORT} ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY} --api S3v4
mc cp --insecure -r /opt/datarobot-runtime/data/backup/ minio/${MINIO_BUCKET}
exit
```

Stop the MinIO dockers on all of the data nodes by running the following command on all data backend nodes:
```bash
docker stop minio
```

<a name="restoring-minio"></a>
## Restoring MinIO
------------------

**NOTE**: Restoring a large dataset can take a significant amount of time, so it is recommended that a terminal multiplexer (e.g. `tmux` or `screen`) is used to manage this restore.  This will prevent accidental disconnection from interrupting a backup and allow you to check the status of the restore.

You will need a directory large enough to accommodate a copy of the MinIO datastore. The instructions provided will create a backup at `/opt/datarobot/data/minio/backup` and any additional disk or external filesystem should be mounted at that location.

You will also need a backup archive created using [the MinIO Backup Instructions](../backup/minio.md) in this guide.

All of the configured MinIO nodes should be running during the restore, however you only need to execute the restore against a single `minio` instance; the restore command will restore the entire MinIO bucket.  Any `minio` instance is acceptable for this restore activity.

On every node configured to host a `minio` docker, start the `minio` instance:
```bash
docker start minio
```

Restoring MinIO should occur on an instance with MinIO already running on it. `docker ps | grep minio` should return a running `minio` docker container.

If it doesn't exist, first create the minio backup directory:
```bash
mkdir /opt/datarobot/data/minio/backup
```

Extract the tar archive of the backed-up MinIO files:
```bash
cd /opt/datarobot/data/minio/backup
tar -xf /opt/datarobot/data/backups/minio/datarobot-minio-backup-<backup_date>.tar
```

Enter the running MinIO docker:
```bash
docker exec -it minio /entrypoint bash
```

Set the required MinIO variables:
```bash
source <(python3 -m config.render -g minio -T "{{minio_env | shexports}}")
```

Create an alias for the local minio instance:
```bash
mc config host add minio https://${MINIO_HOST}:${MINIO_PORT} ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY} --api S3v4
```

Copy the data from the MinIO bucket to the MinIO backup directory:
```bash
mc cp --insecure -r /opt/datarobot-runtime/data/backup minio/${MINIO_BUCKET}/
```

**NOTE**: The `--insecure` flag is used in this instance because the `minio` SSL certifiate authenticates against the host IP address, not 127.0.0.1. Data is still encrypted in transit, but the Certificate Authority is not validated during a localhost copy.

**NOTE**: While MinIO encrypts data at rest inside the MinIO bucket, copying the data out of the bucket will decrypt the data.  Backups created using this mechanism will not be encrypted at rest. Use your corporate data management policies to ensure that this data is protected appropriately.

Exit the running MinIO docker:
```bash
exit
```

On every node configured to host a `minio` docker, stop the `minio` instance:
```bash
docker stop minio
```
