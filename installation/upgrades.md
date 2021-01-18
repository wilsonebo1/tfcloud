# Upgrading DataRobot

If you are upgrading from a previous version of DataRobot, be sure to perform
the following steps to prepare your DataRobot cluster for upgrade.

## Application Server Preparation

Perform the following steps on **all application servers** to avoid issues
during your upgrade.

None of these steps will cause you to lose any data or application state.
However, they will require service downtime for the DataRobot application.

### Preserve secrets

If `secrets_enforced` was true from a previous install, and user/password
authentication is used for services, then the files driving secrets should
be preserved. Namely the file `secrets.yaml` from the installation directory
(which  has `config.yaml` in it), must be copied and preserved for the upgrade
(e.g. copy `secrets.yaml` from previous installation into the new installation
directory).

#### Update secrets

In 5.3, secrets enforced clusters began using a shared secret for Rabbitmq which is written
to an `erlang.cookie` file. Upgrades from <= 5.2 to >= 5.3 must add a `rabbit_cookie: <any_secret_value>`
value to `secrets.yaml`.

### Preserve installer encryption key and encrypted config values

The DataRobot installer may make use internally of encryption and write
encrypted values to disk to avoid preserving them in plaintext.

This is possible even if `secrets_enforced` is not set to true.

In the installation directory, the file `.secrets-key` (n.b. this is a hidden file)
and the directory and all contents of `secrets/` (not to be confused with
secrets.yaml) must be preserved and copied into the new installation directory.

Some features using this functionality may be severaly hampered if this
data is not kept intact between installations, e.g. the user credential storage
system stores an encryption key in this manner.
If the key is not preserved on a re-install or upgrade, any previously stored
credentials would no longer be accessible by the app.

### Preserve Externally Signed TLS Certificates

The DataRobot installer handles distribution of TLS Certificates for both front-end and backend network encryption.  Typically the web-server certificate is issued by a public Certificate Authority and will need to be migrated during the upgrade process.  If this is the case then the `certs/` directory, and all of it's contents, must be copied into the new installation directory.

### Remove old files and services

* Stop kubelet

```bash
systemctl stop kubelet
```

* Stop and remove all containers:

```bash
docker rm $(docker stop $(docker ps -aq))
```

This command will print out a list of numbers similar to the following:
```bash
f581d5af3801
851c9781beb1
eba209849502
77c790ba5b13
...
# There will be about 40 rows.
```

* Remove the DataRobot code directory:

```bash
rm -rf /opt/datarobot/DataRobot/
```

* Remove DataRobot Docker networks

```bash
docker network rm dr-ide
docker network rm dr-usermodel
```

* Stop the Docker daemon:

```bash
systemctl stop docker
```

* Check the installed version of Docker:

```bash
docker --version
```

* If kubernetes was installed, uninstall it completely:

```bash
yum remove -y cri-tools kubeadm kubectl kubelet kubernetes-cni
```

* If the installed version of Docker is below 19.03, uninstall it completely
from every node:

```bash
yum remove -y docker docker-ce docker-ce-cli docker-ce-selinux docker-selinux python-docker-py python-docker-pycreds
```

**NOTE:** If using even older versions of Docker, the package names may be
different.

* Cleanup unnecessary packages:

```bash
yum -y autoremove
```

* Unmount old kubernetes mounts:

```bash
mount | grep kubelet | awk '{ print $3 }' | xargs --no-run-if-empty umount
```

* Remove old kubernetes files:

```bash
rm -rf /etc/cni /etc/kubernetes /opt/datarobot/var/lib/kubelet /var/lib/calico /var/lib/kubelet /var/lib/etcd ~/.kube
```

* Remove old Docker images:

```bash
rm -rf /var/lib/docker /opt/datarobot/registry
```

* Remove old configuration files:

```bash
rm -rf /opt/datarobot/admin/ /opt/datarobot/etc/ /etc/docker/daemon.json
```

* Remove old temporary package files:

```bash
rm -rf /tmp/docker-*
```

### Update configuration files

#### Carry over old files

You will need to first copy the following files and directories, if present, from your previous installation into the new installation directory:

* `.secrets-key`
* `certs/`
* `config.yaml`
* `hadoop-configuration.yaml`
* `secrets.yaml`
* `secrets/`

#### Apply modifications to configuration files

Your `config.yaml` will need to be updated.

Look at the file in `example-configs` most relevant to your install target.
Some new required values may be necessary which are not required in earlier releases.
For example, if using Hadoop, make sure to add required keys per the
`example-configs/*hadoop.yaml` files which are under
_"Additional Hadoop configuration settings"_ (e.g. `WEBHDFS_STORAGE_DIR`, etc.).

Contact DataRobot Support to identify required changes.

Remove the following keys, if present:

* `USER_MODEL_CONTEXT_BASE`
* `SECURE_WORKER_USER_TASK_IMAGE`

On upgrade to version 4.3 the following required changes must be made to `config.yaml`:

1. Remove the instance of the `edabroker` service and replace it with the following two services: `taskmanager` and `rabbit`. There should be exactly one instance of both the `taskmanager` and the `rabbit` services on each cluster.

2. Remove the instance of the `edaworker` service and replace it with the `execmanager` service. NOTE: this component should _not_ be present on Hadoop installs.

On upgrade to version 4.4 the following required changes must be made to `config.yaml`:

1. (Not common) If the `secureworker` service was on a different node than the `execmanager` service, replace `execmanager` with `execmanagereda` and add `execmanagersw` to the node with `secureworker` to retain the same workload distribution. In most configurations, the `secureworker` service is on the same node as the `execmanager` service, and in this case no changes are needed to the configuration.

On upgrade to version 5.0 the following required changes must be made to `config.yaml` for non Hadoop installs:

1. Remove the instance of the `securebroker` service.

2. Find the instance of `secureworker` service.
  * If the `secureworker` service was on a different node than the `execmanager` service, replace `execmanager` with `execmanagereda` and `secureworker` with `execmanagersw` to retain the same workload distribution.

On upgrade to version 5.0 the following required changes must be made to `config.yaml`:

1. On Hadoop installations, add the new `execmanagerqw` service to one of the nodes in your environment. It processes some lightweight jobs which were executed on Hadoop in previous versions. You may have multiple instances of this service on different nodes. Example:

```yaml
---
servers:
# Web server
- services:
  - nginx
  # ...
  - execmanagerqw
```

On upgrade to version 5.1 the following required changes must be made to `config.yaml`:

1. If SAML is used, move SAML certifications to `/opt/datarobot/etc/certs/saml/`.

After making this change, existing database records will need to be updated in the `sso_configuration` collection.
You will need to update document keys, _for all existing records_, to point to the new paths:

  * advanced_configuration.saml_client_configuration.key_file
  * advanced_configuration.saml_client_configuration.cert_file

On upgrade to version 5.3 or higher the following changes should be considered:

* `config.yaml` now supports customizing Docker networks. See [Docker Networking](special-topics/docker-networks.md)
* If secrets are enabled, remove the erlang cookie on all RabbitMQ hosts (located by inspecting your config.yaml) host after services have been stopped.
  These nodes will be labeled Rabbit in config.yaml.
  1. ensure that all datarobot services are stopped
  2. ```mv /opt/datarobot/data/rabbit/data/.erlang.cookie /opt/datarobot/data/rabbit/data/erlang.cookie.bak```
* In 5.3, secrets enforced clusters began using a shared secret for Rabbitmq which is written to an `erlang.cookie` file. Upgrades from <= 5.2 to >= 5.3 must add a `rabbit_cookie: <any_secret_value>` value to `secrets.yaml`.


### Update Network configuration

On upgrade to version 4.3, the following changes to the open ports between hosts must be made:


| Action            | Port  | Protocol | Component            |
|:------------------|------:|:---------|:---------------------|
| Add               | 5672  | TCP      | RabbitMQ |


On upgrade to version 4.4, the following changes to the open ports between hosts must be made:

| Action            | Port  | Protocol | Component            |
|:------------------|------:|:---------|:---------------------|
| Add               | 15672 | TCP      | RabbitMQ HTTP Interface|


On upgrade to version 5.0, the following changes to the open ports between hosts must be made:

| Action            | Port  | Protocol | Component            |
|:------------------|------:|:---------|:---------------------|
| Optionally Remove | 5558  | TCP      | Secure Worker Broker Client |
| Optionally Remove | 5556  | TCP      | Secure Worker Broker |


Starting with the 5.3 release of DataRobot, RabbitMQ supports  high  availability

| Action            | Port  | Protocol | Component            |
|:------------------|------:|:---------|:---------------------|
| HA RabbitMQ enabled | 5673  | TCP    | high availability port |
| HA RabbitMQ enabled | 15673 | TCP    | high availability port |
| HA RabbitMQ enabled | 25672 | TCP    | high availability port |


### Upgrade Model Monitoring and Management

Starting with DataRobot release 5.0, model monitoring and management is receiving vast performance
and scaling improvements. As a consequence of this improvement, all historical data is no longer
visible in existing deployments, and drift tracking has been disabled for them. The data has not
been removed, only archived. **In order to continue tracking drift for existing deployment, you will
need to re-enable drift tracking for each of them.** Any deployment data created on release 4.4.1 of
DataRobot (or later) can be migrated into the new model monitoring and management storage tables by
performing a data upgrade process. See
[Model Management Data Upgrade](special-topics/model-management-data-upgrade.md) for additional
details.

## Cloudera Preparation

* Log into the Cloudera Manager.
* Stop the DataRobot service.
* Delete the DataRobot service.
* Deactivate the DataRobot parcel.

## Ambari Preparation

* Log into the Ambari Manager.
* Stop the DataRobot service.
* Delete the DataRobot service.

### RabbitMQ high availability

Starting with DataRobot 5.3, it's possible  to enable clustered RabbitMQ to enhance durabiliy. If HA RabbitMQ is enabled, it will be necessary to add the port exceptions mentioned above. See [High Availability RabbitMQ](special-topics/rabbitmq-ha.md) for details on how to configure RabbitMQ in High Availability mode.


### Gluster Migration to MinIO

Starting with DataRobot 5.3, the Gluster storage backend has been deprecated and will be removed
from the DataRobot Platform in a future release.  Customers upgrading from prior releases should
plan to migrate data from Gluster to another storage backend.  See
[Gluster Migration](special-topics/gluster-migration.md) for details on how to migrate to the
new MinIO storage backend.

**NOTE**: MinIO provides encryption-at-rest for data stored in the `minio` service and creates a `minio_sse_master_key` as part of the installation/upgrade process.  The `minio_see_master_key` is set, and managed, by the DataRobot secrets system and should be regularly backed up.  If this key is lost, access to the data stored in the `minio` subsystem will become inaccessible.  All care should be taken to avoid misplacing or losing the `minio_sse_master_key` as it cannot be regenerated without incurring data loss.

### Gluster

Starting with DataRobot 5.3, the Gluster storage backend has been deprecated and will be removed from the DataRobot Platform in the 7.0 release.  Customers upgrading from prior releases should plan to migrate data from Gluster to another storage backend.  See [Gluster Migration](special-topics/gluster-migration.md) for details on how to migrate to the new MinIO storage backend.

Starting with DataRobot 6.3, DataRobot defaults to running Docker containers in read-only mode.  Because Gluster is unable to support this configuration, customers still using Gluster will need to disable read-only mode in `config.yaml`.

```yaml
app_configuration:
  read_only_containers: false
```

Failure to disable read-only containers will result in `glfs_init(<id>) failed: Read-only file system` errors during upload.

Starting with DataRobot 7.0, Gluster is no longer supported as a storage backend.  Any upgrades taking DataRobot to version 7.0 or beyond must first migrate any existing Gluster storage to an alternative backend (for example: AWS S3, Azure Blob, Google Compute Storage, or the bundled MinIO service).  Please consult with your Customer Success team to plan an appropriate storage migration plan prior to upgrading to 7.0 or beyond if your current implementation includes Gluster.

### Hyper API Service to Tableau Integrations Service

Starting with DataRobot 7.0, the Hyper API service has been modified to host the DataRobot Tableau Analytics Extension server.
Since this service now supports two different integrations, it makes sense to rename the service to better reflect its usage in DataRobot.
The new service has been changed from `hyper-api-service` to `tableau-integrations`

The following environment variables have been renamed, though existing environment variables set for the Hyper API Service will still be used if the new variables are not set:

```
HYPER_API_SERVICE_GUNICORN_BIND -> TABLEAU_INTEGRATIONS_SERVICE_GUNICORN_BIND
HYPER_API_SERVICE_GUNICORN_MAX_REQUESTS -> TABLEAU_INTEGRATIONS_SERVICE_GUNICORN_MAX_REQUESTS
HYPER_API_SERVICE_GUNICORN_TIMEOUT -> TABLEAU_INTEGRATIONS_SERVICE_GUNICORN_TIMEOUT
HYPER_API_SERVICE_GUNICORN_WORKERS -> TABLEAU_INTEGRATIONS_SERVICE_GUNICORN_WORKERS
```

### Mongo Version and Old DataRobot Versions

Starting with DataRobot release 5.3, the old mongo 2.3->3.4 upgrade tooling has been deprecated. This tooling automatically converted old mongo data into WiredTiger format and made other changes.

As a consequence of this change, for customers on 4.0.x (or earlier releases), they will require upgrading to a version before 5.3.x before upgrading to 5.3.x.

For example, a customer on 4.0.x and mongo 2.4 could be upgraded to 4.4.x or 5.2.x first. This will bring them up to mongo 3.4. Then they could be upgraded to 5.3.x (or later), upgrading to mongo 3.6 (or later).

It is expected that trying to install mongo 3.6 or later on a system using old mongo data (not previously upgraded to 3.4 and WiredTiger), that the DataRobot mongo service/containers will fail to start, or otherwise yield error messages in the logs about "WiredTiger" or incompatible/unreadable mongo data.

### Elasticsearch Backup and Restore

Starting with DataRobot release 5.1, Elasticsearch is provided as a storage mechanism for the AI Catalog premium feature. If AI Catalogs are part of the DataRobot installation it is recommended that the DataRobot installation is configured for elasticsearch backup/restore as part of the upgrade process. Please see the DataRobot Backup/Restore guide for details regarding how to configure elasticsearch for backup and restore activities.
