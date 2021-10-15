# Upgrading DataRobot

If you are upgrading from a previous version of DataRobot, be sure to perform
the following steps to prepare your DataRobot cluster for upgrade.

## Application Server Preparation

Perform the following steps on **all application servers** to avoid issues
during your upgrade.

None of these steps will cause you to lose any data or application state.
However, they will require service downtime for the DataRobot application.

Starting in 7.1.0, mongo upgrades will be part of the installation
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

- `/opt/datarobot/sbin/datarobot-manage-mongo --help`
- `/opt/datarobot/sbin/datarobot-manage-mongo backup --help`


### Remove old files and services

* Stop all DataRobot services:

```bash
bin/datarobot services stop
```

* Remove the DataRobot directories:

```bash
cd /opt/datarobot
rm -rf app autocomplete bin cuda* DataRobot docker dss etc html \
    include lib libexec logs odbc pyenv quantum* sbin share src \
    ssl syslog usr var virtualenvs
```
* Remove old temporary package files:

```bash
rm -rf /tmp/datarobot-packages*
```

### Uninstall old RPMs

```bash
rpm -qa | grep -i datarobot | xargs --no-run-if-empty yum erase -y
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

On upgrade to version 4.4, the following changes to the open ports between hosts must be made:


| Action            | Port  | Protocol | Component            |
|:------------------|------:|:---------|:---------------------|
| Add               | 15672 | TCP      | RabbitMQ HTTP Interface|


On upgrade to version 5.0, the following changes to the open ports between hosts must be made:


| Action            | Port  | Protocol | Component            |
|:------------------|------:|:---------|:---------------------|
| Optionally Remove | 5558  | TCP      | Secure Worker Broker Client |
| Optionally Remove | 5556  | TCP      | Secure Worker Broker |

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

