# Hadoop Installation Instructions

DataRobot can integrate with Cloudera and Ambari Hadoop distributions.
Supported Ambari distributions include Hortonworks and IBM BigInsights.

## Create Config Files

To enable this integration, first create `hadoop-configuration.yaml` and `config.yaml`.

### hadoop-configuration.yaml

Place a file like the following in `/opt/DataRobot-4.0.x/`

```yaml
# FILE: hadoop-configuration.yaml
---
cluster_name: <name of hadoop cluster>
manager_address: <address of Ambari or Cloudera Manager>
# Set these to true if the Cloudera Manager or Ambari is using SSL/TLS
use_tls: false
ignore_ca: false
```

Verify your file is correctly configured with

```bin
./bin/datarobot validate
```

### config.yaml

Copy a sample YAML configuration file to `/opt/DataRobot-4.0.x/config.yaml`.

You can find a sample Cloudera `config.yaml` file in `example-configs/multi-node.hadoop.yaml`. Modify the sample to suit your
environment.

Contact DataRobot support for help with this file.

## Hadoop Installation

Now, use the following sections install DataRobot on Hadoop.

* [Cloudera Installation](cloudera-install.md)
* [Hortonworks/BigInsights Installation](ambari-install.md)

When complete, proceed to synchronize configuration.

## Synchronize Configuration

**NOTE**: This section assumes you have completed the [Linux Installation](standard-install.md) portion of the installation process, and
one of the [Hadoop Installation)(hadoop-install.md#hadoop-installation)
process for either Cloudera or Ambari Hadoop.

Now, DataRobot needs to synchronize configuration between the application
servers and the Cloudera cluster.

* SSH into the application server as the DataRobot user.

* Start the configuration synchronization process.

```bash
cd /opt/DataRobot-4.0.x/
./bin/datarobot hadoop-sync
```

When prompted, enter credentials to access the Cloudera Manager.
Credentials can also be passed as environment variables or CLI arguments.

The user you authenticate with must have permissions to modify configuration
of the DataRobot service and restart services. The provisioner will post configuration
information to the Cloudera Manager and trigger a restart of the DataRobot service.

* When the DataRobot service restarts, it copies configuration files to the
application server, which triggers a configuration synchronization process on
the application server that restarts services.

* Verify that the installation and configuration have successfully completed:

```bash
./bin/datarobot health hadoop-health
```

* Generate the initial admin account for the DataRobot application:

```bash
docker exec app create_initial_admin.sh
```

You can now open the DataRobot application in your web browser by pointing it
to `http://[APPLICATION SERVER FQDN OR IP ADDRESS]` and logging in using the
credentials printed out by the previous command.

You should use this account for creating new users and modifying user permissions only.

Installation is now complete.
