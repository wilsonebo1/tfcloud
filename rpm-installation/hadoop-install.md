# Hadoop Installation Instructions

DataRobot can integrate with Cloudera Hadoop distribution.

## Create Config Files

To enable this integration, first create `hadoop-configuration.yaml` and `config.yaml`.

### hadoop-configuration.yaml

Place a file like the following in `/opt/datarobot/DataRobot-4.5.x/`

```yaml
# FILE: hadoop-configuration.yaml
---
cluster_name: <name of hadoop cluster>
manager_address: <address of Hadoop Manager>
manager_type: cloudera
# Optional
# cm_api_version: <cloudera manager api version>
# Set these to true if the Hadoop Manager is using SSL/TLS
use_tls: false
ignore_ca: false
```

More information about the SSL/TLS keys can be found in the [TLS Guide](installation/special-topics/tls.md#cm-tls)

Verify your file is correctly configured with

```bin
chmod 0600 hadoop-configuration.yaml
./bin/datarobot validate
```

### config.yaml

Copy a sample YAML configuration file to `/opt/datarobot/DataRobot-4.5.x/config.yaml`.

You can find a sample Cloudera `config.yaml` file in `example-configs/single-node-poc.hadoop.yaml`. Modify the sample to suit your
environment.

Contact DataRobot support for help with this file.

## Hadoop Installation

Now, use the following sections install DataRobot on Hadoop.

* [Cloudera Installation](cloudera-install.md)

When complete, proceed to synchronize configuration.

## Synchronize Configuration

**NOTE**: This section assumes you have completed the [Linux Installation](standard-install.md) portion of the installation process, and
the [Hadoop Installation](hadoop-install.md#hadoop-installation) process.

Now, DataRobot needs to synchronize configuration between the application
servers and the Hadoop cluster.

* SSH into the application server as the DataRobot user.

* Start the configuration synchronization process.

```bash
cd /opt/datarobot/DataRobot-4.5.x/
source release/profile
./bin/datarobot hadoop-sync
```

When prompted, enter credentials to access the Hadoop Manager.
Credentials can also be passed as environment variables or CLI arguments.

The user you authenticate with must have permissions to modify configuration
of the DataRobot service and restart services. The provisioner will post configuration
information to the Hadoop Manager and trigger a restart of the DataRobot service.

* When the DataRobot service restarts, it copies configuration files to the
application server, which triggers a configuration synchronization process on
the application server that restarts services.

You can now open the DataRobot application in your web browser by pointing it
to `http://[APPLICATION SERVER FQDN OR IP ADDRESS]` and logging in using the
credentials printed out at the end of the [Linux Installation](standard-install.md#linux-provision) process.

Installation is now complete.
