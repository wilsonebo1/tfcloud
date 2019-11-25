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

### Remove old files and services

* Stop all DataRobot services for RHEL7:

```bash
systemctl stop datarobot.target
systemctl stop datarobot-hadoop-config-sync
```

* Alternatively, if on RHEL6, stop all DataRobot services:

```bash
initctl stop datarobot.target
initctl stop datarobot-hadoop-config-sync
```

* Remove all DataRobot service files:

```bash
rm -rf /etc/systemd/system/datarobot*
rm -rf /etc/init/datarobot*
```

* If on RHEL7, reload and clear `systemctl`:

```bash
systemctl daemon-reload
systemctl reset-failed
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

### Update configuration files

#### Carry over old files

You will need to first copy the following files, if present, from your previous installation into the new installation directory:

* `config.yaml`
* `hadoop-configuration.yaml`
* `secrets.yaml`

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

On upgrade to version 5.2 the following required changes must be made to `config.yaml`:

1. If SAML is used, move SAML certifications to `/opt/datarobot/etc/certs/saml/`.

After making this change, existing database records will need to be updated in the `sso_configuration` collection.
You will need to update document keys, _for all existing records_, to point to the new paths:

  * advanced_configuration.saml_client_configuration.key_file
  * advanced_configuration.saml_client_configuration.cert_file


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
