# Upgrading DataRobot

If you are upgrading from a previous version of DataRobot, be sure to perform
the following steps to prepare your DataRobot cluster for upgrade.

## Application Server Preparation

Perform the following steps on **all application servers** to avoid issues
during your upgrade.

None of these steps will cause you to lose any data or application state.
However, they will require service downtime for the DataRobot application.

### Remove old files and services

* Stop all DataRobot services for RHEL7:

```bash
systemctl stop datarobot.target
```

* Alternatively, if on RHEL6, stop all DataRobot services:

```bash
initctl stop datarobot.target
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

On upgrade to version 4.5 the following required changes must be made to `config.yaml` for non Hadoop installs:

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

 2. On Hadoop installations, set the new flag `SKIP_DSS_REST_AND_NEXT_STEPS_SERVICES` to `true` to enable `execmanagerqw`.
    ```yaml
    
    ---
    app_configuration:
        drenv_override:
            SKIP_DSS_REST_AND_NEXT_STEPS_SERVICES: true

### Update Network configuration

On upgrade to version 4.4, the following changes to the open ports between hosts must be made:


| Action            | Port  | Protocol | Component            |
|:------------------|------:|:---------|:---------------------|
| Add               | 15672 | TCP      | RabbitMQ HTTP Interface|


On upgrade to version 4.5, the following changes to the open ports between hosts must be made:


| Action            | Port  | Protocol | Component            |
|:------------------|------:|:---------|:---------------------|
| Optionally Remove | 5558  | TCP      | Secure Worker Broker Client |
| Optionally Remove | 5556  | TCP      | Secure Worker Broker |


## Cloudera Preparation

* Log into the Cloudera Manager.
* Stop the DataRobot service.
* Delete the DataRobot service.
* Deactivate the DataRobot parcel.

## Ambari Preparation

* Log into the Ambari Manager.
* Stop the DataRobot service.
* Delete the DataRobot service.
