# Migrating Local Filestore to MinIO

To migrate data to the MinIO Filestore MinIO but be up and running.  PLease follow the [Using the MinIO Filestore Backend](minio-filestore.md) directions included in this guide before proceeding.

It is assumed that your DataRobot instance is operational and the Local Filestore is currently in use; following these dirctions if MinIO is the current filestore can result in lost data.  Please make sure that your `config.yaml` is currently configured with `FILE_STORAGE_TYPE: local` and that all services are using the local filestore.

## Migrating Local Filestore Data to MinIO

The majority of this operation is safe to perform while DataRobot is operating, but it will put additional load on the disk subsystem, as such it is recommended that application performance is monitored during migration activities.  The MinIO migration activity requires twice as much disk space as is used prior to the start of migration: one copy of the data will remain active on the local filesystem and one copy of the data will be active in MinIO.  At the end of the migration you can delete the data store you will no longer use.

It is highly recommended that the minio disk subsystem not be NFS mounted; this may mean that the current datastore and minio will be on different filesystems.

Running the following command, while MinIO is running will migrate local filestore data into MinIO:
```bash
/opt/datarobot/app/DataRobot/sbin/datarobot-migrate-minio
```

**NOTE**: This step can be performed multiple times and will only copy new data from the local filesystem to minio.  The first time you run this command it will copy all local filesystem data to MinIO and may take several hours to complete; the second time you run it only data added after the first synchronization will be copied and the process will be much faster.

From the provisioner, as a user with `sudo` access, stop the DataRobot Platform services:

```bash
bin/datarobot services stop
```

Start the MinIO service on every host configured to run MinIO:

CentOS 6 or RHEL 6
```bash
service datarobot-minio start
```

CentOS 7 or RHEL 7
```bash
systemctl start datarobot-minio
```

Perform a final data copy with the DataRobot application offline:

```bash
/opt/datarobot/app/DataRobot/sbin/datarobot-migrate-minio
```

Modify `config.yaml` to use the `s3` backend:

```yaml
# config.yaml snippet
[...]
app_configuration:
  [...]
  drenv_override:
    [...]
    FILE_STORAGE_TYPE: s3
    [...]
```


Stop the MinIO service on every host configured to run MinIO:

CentOS 6 or RHEL 6
```bash
service datarobot-minio stop
```

CentOS 7 or RHEL 7
```bash
systemctl stop datarobot-minio
```


Distribute the configuration to all of the DataRobot notes:

### If passwordless ssh has been configured:

From the provisioner, as a user with `sudo` access, start the DataRobot Platform services:
```bash
bin/datarobot services start
```

Run the following command on the provisioner host as the user with `sudo` access on every node in the cluster:
```bash
bin/datarobot setup-dependencies
```

Run the following command on the provisioner host as the `datarobot` user:
```bash
bin/datarobot install --pre-configure
```

From the provisioner, as a user with `sudo` access, restart the DataRobot Platform services:
```bash
bin/datarobot services restart
```

From the provisioner, as the `datarobot` user, finish the install process:
```bash
bin/datarobot install --post-configure
```

From the provisioner, as a user with `sudo` access, restart the DataRobot Platform services:
```bash
bin/datarobot services restart
```

Verify the MinIO service is healthy by running the following command on each host with the `minio` service defined:

```bash
curl localhost:9090/v1/health/?service=minio
```

Once you have confirmed that the application is performing normally it is reasonable to remove the local filestore from the DataRobot application servers.

### If passwordless ssh has not been configured

On each host in the cluster, start the DataRobot services as a user with `sudo` access:
```bash
bin/datarobot services start --limit-hosts <host IP>
```

Run the following command on each host in the cluster as a user who has `sudo` access on that host:
```bash
bin/datarobot setup-dependencies --limit-hosts <host IP>
```

Run the following command on a single host in the cluster as the `datarobot` user:
```bash
bin/datarobot install --pre-configure --limit-hosts <host IP>
```

On each host in the cluster, restart the DataRobot services as a user with `sudo` access:
```bash
bin/datarobot services restart --limit-hosts <host IP>
```

On each host in the cluster, finish the DataRobot install steps as the `datarobot` user:
```bash
bin/datarobot --post-configure --limit-hosts <host IP>
```

On each host in the cluster, restart the DataRobot services as a user with `sudo` access:
```bash
bin/datarobot services restart --limit-hosts <host IP>
```

Verify the MinIO service is healthy by running the following command on each host with the `minio` service defined:

```bash
curl localhost:9090/v1/health/?service=minio
```

Once you have confirmed that the application is performing normally it is reasonable to remove the local filestore from the DataRobot application servers.
