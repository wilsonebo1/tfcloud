# Upgrading DataRobot

If you are upgrading from a previous version of DataRobot, be sure to perform
the following steps to prepare your DataRobot cluster for upgrade.

## Application Server Preparation

Perform the following steps on **all application servers** to avoid issues
during your upgrade.

None of these steps will cause you to lose any data or application state.
However, they will require service downtime for the DataRobot application.

Starting in 7.1.0 mongo upgrades will be part of the installation
process. **Back up your mongo data before running any upgrades!**

### Preserve secrets

If `secrets_enforced` was true from a previous install, and user/password
authentication is used for services, then the files driving secrets should
be preserved. You will need to first copy the following files and directories, if present, from your previous installation into the new installation directory:

* `.secrets-key`
* `certs/`
* `secrets.yaml`
* `secrets/`

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

### Back Up Mongo Data

Starting in 7.1.0, the DataRobot installer will always perform an in-place upgrade of
your database. It will detect the current version and attempt to upgrade to
the mongo version of the new installation. While the risk in minimal, the
cost of _not_ backing up your data is huge.

Please backup your data using
[datarobot-manage-mongo backup](./backup-mongo.md).

Or directly access help commands here:

- `docker exec -it mongo /entrypoint sbin/datarobot-manage-mongo --help`
- `docker exec -it mongo /entrypoint sbin/datarobot-manage-mongo backup --help`


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

Also, you would need to remove the "exclude" in /etc/yum.conf if below line is there.
```bash
exclude=container-selinux* containerd.io* docker-ce* docker-ce-cli* libnvidia-container-tools* libnvidia-container1* nvidia-container-runtime* nvidia-container-toolkit* nvidia-docker2* python-docker-pycreds* python-websocket-client* python2-docker* python2-requests* python2-six*
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

### Create Configuration Files

* Copy the template config file from `example-configs` most relevant to your install target into your installation directory.

  ```bash
  cp example-configs/multi-node.yaml config.yaml
  chmod 0600 config.yaml
  ```

* Open `config.yaml` with a text editor and update it with any cluster-specific values such as users, IP addresses, external URLs, or backend storage details.

* Remove the following keys, if present:

  * `USER_MODEL_CONTEXT_BASE`
  * `SECURE_WORKER_USER_TASK_IMAGE`
  * `PYTHON3_SERVICES`
    
    Upgrades of existing clusters from versions prior to 7.1 **SHOULD NOT** set `PYTHON3_SERVICES` to `True`, but should omit this setting from `config.yaml` entirely to prevent backwards compatibility issues with pre-existing python 2 projects.  A supported upgraded path for python 2 projects will be provided in subsequent releases after 7.1.

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

On upgrade to version 7.2, the following changes to the open ports between hosts must be made:

| Action            | Port  | Protocol | Component            |
|:------------------|------:|:---------|:---------------------|
| Optionally Remove | 5445  | TCP      | IDE Client Broker |
| Optionally Remove | 5446  | TCP      | IDE Client Worker |
| Optionally Remove | 5555  | TCP      | Worker Broker Client |


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

The release 7.2 removes Model Monitoring and Management's dependency on TimescaleDB. In order to
accommodate this change, upgrades of the platform from versions prior to 5.3.x should first upgrade 
to 5.3.x, and then upgrade to the current version.  

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


### Gluster

The Gluster storage has been deprecated in 7.0. Suppose the system needs to be migrated to MinIO; customers will need to upgrade the system to 7.0.x and run through "Gluster Migration to MinIO" instruction first before upgrading the system to 7.1 after. 


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

Starting with DataRobot release 5.3, the old mongo 2.3->3.4 upgrade tooling has been deprecated. 
This tooling automatically converted old mongo data into WiredTiger format and made other changes.

As a consequence of this change, for customers on 4.0.x (or earlier releases), 
they will require upgrading to a version before 5.3.x before upgrading to 5.3.x.

For example, a customer on 4.0.x and mongo 2.4 could be upgraded to 4.4.x or 5.2.x first. 
This will bring them up to mongo 3.4. Then they could be upgraded to 5.3.x (or later),
upgrading to mongo 3.6 (or later).

If you try to install mongo 3.6 or later on a system using old mongo data
(not previously upgraded to 3.4 and WiredTiger), the DataRobot mongo service/containers will fail to start
or will yield error messages in the logs about "WiredTiger" or incompatible/unreadable mongo data.

Starting in DataRobot 7.1.0, the installer will automatically check the version of your mongo data and
upgrade it to the mongo version shipped with DataRobot. This requires mongo 3.4 or later and WiredTiger.

### Elasticsearch Backup and Restore

Starting with DataRobot release 5.1, Elasticsearch is provided as a storage mechanism for the AI Catalog premium feature. If AI Catalogs are part of the DataRobot installation, there is **NO** need to configure backup and restore. During DataRobot startup, DataRobot will rebuild the Elasticsearch index when the Elasticsearch index is empty. The rebuild time will vary based on the size of the catalog, but it is generally faster than a backup or restore.
