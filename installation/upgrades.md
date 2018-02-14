# Upgrading DataRobot

If you are upgrading from a previous version of DataRobot, be sure to perform
the following steps to prepare your DataRobot cluster for upgrade.

## Application Server Preparation

Perform the following steps on **all application servers** to avoid issues
during your upgrade.

None of these steps will cause you to lose any data or application state.
However, they will require service downtime for the DataRobot application.

### Remove old files and services

* Stop and remove all containers.

```bash
docker rm $(docker stop $(docker ps -aq))
```

* Remove the DataRobot code directory:

```bash
rm -rf /opt/datarobot/DataRobot/
```

* Stop the Docker daemon

```bash
systemctl stop docker
```

* If your installed version of Docker is below 17.03, uninstall it completely
from every node.

```bash
yum remove -y docker docker-selinux
```

**NOTE:** If using even older versions of Docker, the package names may be
different.

* Remove old Docker images

```bash
rm -rf /var/lib/docker/*
rm -rf /opt/datarobot/registry
```
* Remove old configuration files

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
