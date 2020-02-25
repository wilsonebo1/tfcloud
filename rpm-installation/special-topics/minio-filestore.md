# Using the MinIO Filestore Backend

DataRobot optionally includes the ability to use MinIO as a Filestore backend; this service provides authentication, TLS encryption for data in-transit, and encryption for data at rest.

To enable the MinIO Filestore Backend, [Database Password Protection](database-passwords.md) must be enabled.  Please follow the directions included in this guide before proceeding.

**NOTE**: MinIO provides encryption-at-rest for data stored in the `minio` service and creates a `minio_sse_master_key` as part of the installation/upgrade process.  The `minio_see_master_key` is set, and managed, by the DataRobot secrets system and should be regularly backed up.  If this key is lost, access to the data stored in the `minio` subsystem will become inaccessible.  All care should be taken to avoid misplacing or losing the `minio_sse_master_key` as it cannot be regenerated without incurring data loss.

## Enabling the MinIO Filestore Backend

### If passwordless ssh has been configured

Add the `minio` service to your `config.yaml`:
```yaml
# config.yaml snippet
[...]
servers:
  [...]
  - services:
    [...]
    - minio
    [...]
```

If local file storage was previously used, also confirm that `FILE_STORAGE_TYPE` is set to `local`:
```yaml
#config.yaml snippet
[...]
app_configuration:
  [...]
  drenv_override:
    [...]
    FILE_STORAGE_TYPE: local
    [...]
```

**NOTE**: MinIO will provide a highly-available repository if multiple `minio` services are configured.  Adding more `minio` services will increase the resiliency of the solution; it is recommended that you add a `minio` service to each data node in your DataRobot cluster.

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

If local storage was previously used in this installation, follow the [Migrating Local Data to Minio](migrating-local-data-to-minio.md) instructions in this guide.


### If passwordless ssh has not been configured

Add the `minio` service to your `config.yaml`:
```yaml
# config.yaml snippet
[...]
servers:
  [...]
  - services:
    [...]
    - minio
    [...]
```

If local file storage was previously used, also confirm that `FILE_STORAGE_TYPE` is set to `local`:
```yaml
#config.yaml snippet
[...]
app_configuration:
  [...]
  drenv_override:
    [...]
    FILE_STORAGE_TYPE: local
    [...]
```

**NOTE**: MinIO will provide a highly-available repository if multiple `minio` services are configured.  Adding more `minio` services will increase the resiliency of the solution; it is recommended that you add a `minio` service to each data node in your DataRobot cluster.

Run the following command on each host in the cluster as a user who has `sudo` access on that host:
```bash
bin/datarobot setup-dependencies --limit-hosts <host IP>
```

Run the following command on a single host in the cluster as the `datarobot` user:
```bash
bin/datarobot install --pre-configure --limit-hosts <host IP>
```

As the `datarobot` user, copy `secrets.yaml`, `.secret-key`, and the `secrets\` directory and all of its contents to all the other hosts in the cluster:
```bash
scp -Cp secrets.yaml <host>:/opt/tmp
scp -Cp .secret-key <host>:/opt/tmp
scp -rCp secrets <host>:/opt/tmp
```

As the `datarobot` user, run the following command on each host in the cluster where you have not yet run this command:
```bash
bin/datarobot --pre-configure --limit-hosts <host IP>
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

If local storage was previously used in this installation, follow the [Migrating Local Data to Minio](migrating-local-data-to-minio.md) instructions in this guide.
