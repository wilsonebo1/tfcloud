# Hadoop Installation Instructions

**NOTE**: This section assumes you have completed the installation process on application server.

DataRobot can integrate with Cloudera and Hortonworks Hadoop distributions.

## Create Config Files

To enable this integration, first create `config.yaml`.

### config.yaml

Copy a sample YAML configuration file to `/opt/datarobot/DataRobot-7.x.x/config.yaml`.

You can find a sample Cloudera `config.yaml` file in `example-configs/hadoop-multi-node.yaml`. Modify the sample to suit your
environment.

Contact DataRobot support for help with this file.

## Hadoop Upgrade

**NOTE**: Skip this section if DataRobot is being installed for the first time.

* Stop DataRobot service via Cloudera/Ambari UI

* If the new version is 6.0+ remove DataRobot DSS ETL Quick Worker from the services via Cloudera/Ambari UI since we removed this service from our Hadoop stack started from the 6.0 version.

* Remove any existing datarobot-defaults.conf, datarobot-hadoop.conf on Hadoop node which runs DataRobot Master service.

```bash
# ssh into the Hadoop node which runs DataRobot Master
find / -name "datarobot-defaults.conf" -delete
find / -name "datarobot-hadoop.conf" -delete
# Remove any existing files
```

* Remove CSD files of old DataRobot service on cloudera master node before parcel distribution.

```bash
# ssh into the Hadoop node which runs Cloudera Master
find / -name "DataRobot*.jar"
# Remove any existing files
```

## Hadoop Installation

Now, use the following sections to install DataRobot on Hadoop.

* [Cloudera Installation](cloudera-install.md)
* [Hortonworks Installation](ambari-install.md)

* When the DataRobot service starts, it copies configuration files (datarobot-hadoop.conf, kerberos configs)
to the application server, which restarts services on application server.

* Verify that the installation and configuration have successfully completed:

```bash
./bin/datarobot health hadoop-health
```

* Generate the initial admin account for the DataRobot application:

```bash
./bin/datarobot users reset-admin-credentials
```

You can now open the DataRobot application in your web browser by pointing it
to `http://[APPLICATION SERVER FQDN OR IP ADDRESS]` and logging in using the
credentials printed out by the previous command.

You should use this account for creating new users and modifying user permissions only.

Installation is now complete.

## Reconfigure

**NOTE**: This section assumes you have completed the Installation process and
DataRobot is working in Hadoop environment.

**NOTE**: Never modify DataRobot configuration in the Cloudera or Ambari manager interface.

To update configuration of a cluster:

* Edit `config.yaml` to reflect your desired changes.
* Run `./bin/datarobot reconfigure` from the application server installer directory.

To debug configuration in a running container on application server:

```bash
# get full list of configuration
docker exec CONTAINER_NAME /entrypoint datarobot-get-config
# Eg: docker exec hadoopconfigsync /entrypoint datarobot-get-config
```
