# Upgrading DataRobot

If you are upgrading from a previous version of DataRobot, be sure to perform
the following steps to prepare your DataRobot cluster for upgrade.

## Application Server Preparation

Perform the following steps on **all application servers** to avoid issues
during your upgrade.

None of these steps will cause you to lose any data or application state.
However, they will require service downtime for the DataRobot application.

### Remove old files and services

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

* Stop the Docker daemon:

```bash
systemctl stop docker
```

* Check the installed version of Docker:

```bash
docker --version
```

* If the installed version of Docker is below 18.03, uninstall it completely
from every node:

```bash
yum remove -y docker docker-ce-selinux docker-selinux python-docker-py
```

**NOTE:** If using even older versions of Docker, the package names may be
different.

* Remove old Docker images:

```bash
rm -rf /var/lib/docker
rm -rf /opt/datarobot/registry
```

* Remove old configuration files:

```bash
rm -rf /opt/datarobot/etc/
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

On upgrade to version 4.3 the following required changes must be made to `config.yaml`:

1. Remove the instance of the `edabroker` service and replace it with the following two services: `taskmanager` and `rabbit`. There should be exactly one instance of both the `taskmanager` and the `rabbit` services on each cluster.

2. Remove the instance of the `edaworker` service and replace it with the `execmanager` service. NOTE: this component should _not_ be present on Hadoop installs.

On upgrade to version 4.4 the following required changes must be made to `config.yaml`:

1. (Not common) If the `secureworker` service was on a different node than the `execmanager` service, replace `execmanager` with `execmanagereda` and add `execmanagersw` to the node with `secureworker` to retain the same workload distribution. In most configurations, the `secureworker` service is on the same node as the `execmanager` service, and in this case no changes are needed to the configuration.

On upgrade to version 4.5 the following required changes must be made to `config.yaml` for non Hadoop installs:

1. Remove the instance of the `securebroker` service.

2. Find the instance of `secureworker` service.
  * If the `secureworker` service was on a different node than the `execmanager` service, replace `execmanager` with `execmanagereda` and `secureworker` with `execmanagersw` to retain the same workload distribution.

### Update Network configuration

On upgrade to version 4.3, the following changes to the open ports between hosts must be made:


| Action            | Port  | Protocol | Component            |
|:------------------|------:|:---------|:---------------------|
| Add               | 5672  | TCP      | RabbitMQ |
| Optionally Remove | 5555  | TCP      | Worker Broker Client |
| Optionally Remove | 5556  | TCP      | Worker Broker |


On upgrade to version 4.4, the following changes to the open ports between hosts must be made:


| Action            | Port  | Protocol | Component            |
|:------------------|------:|:---------|:---------------------|
| Add               | 15672 | TCP      | RabbitMQ HTTP Interface|


On upgrade to version 4.5, the following changes to the open ports between hosts must be made:


| Action            | Port  | Protocol | Component            |
|:------------------|------:|:---------|:---------------------|
| Optionally Remove | 5558  | TCP      | Secure Worker Broker Client |
| Optionally Remove | 5556  | TCP      | Secure Worker Broker |



### Upgrade mongo data

Starting with DataRobot release 4.2 the version of mongo has been upgraded from 2.4 to 3.4.
The mongo storage engine has been upgraded to WiredTiger.
Customers upgrading from prior releases will need to go through a data upgrade process.
See [Mongo Data Upgrade](special-topics/mongo-data-upgrade.md) for additional details.

## Cloudera Preparation

* Log into the Cloudera Manager.
* Stop the DataRobot service.
* Delete the DataRobot service.
* Deactivate the DataRobot parcel.

## Ambari Preparation

* Log into the Ambari Manager.
* Stop the DataRobot service.
* Delete the DataRobot service.
