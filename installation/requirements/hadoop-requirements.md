{% block hadoop_integration_requirements %}
# DataRobot Hadoop Integration Requirements

Please note that multiple restarts of your Hadoop cluster will be required.

DataRobot is installable as a parcel that can run on your organization's Hadoop cluster.

DataRobot can integrate with Cloudera and Hortonworks (Ambari) Hadoop distributions.
{% endblock %}

**NOTE**: DataRobot supports only parcels as a format of software distribution for a Hadoop cluster.
Deployment via system specific packages (RPM, DEB, etc.) is not supported.

DataRobot is not supported on Hadoop clusters that use Sentry security because Sentry does not allow impersonation.

## Access Requirements

The administrator must have permission to access the Hadoop Manager
via SSH and perform superuser actions such as moving files, installing packages,
changing permissions, and restarting services.

## Hadoop Requirements

* For Java 8 systems, Oracle Java JDK version greater than or equal to
`1.8.0_60` must be installed.
* HDFS, Yarn, Spark on Yarn, and ZooKeeper must be installed.
* Yarn client must be installed on all nodes where DataRobot services will be installed.
* The fully qualified domain name (FQDN) or IP address of the Hadoop
Manager server must be known.
* The /tmp directory on the Hadoop Manager must be writable and have
at least 5GB of available space.
* If [Transparent Encryption in HDFS](http://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/TransparentEncryption.html) is enabled, [HttpFS](https://hadoop.apache.org/docs/stable/hadoop-kms/index.html) is required.
* The only supported Hadoop storage system is HDFS. Other Hadoop storage systems, including `EMC Isilon`, are not supported.

## Hadoop Recommendations

To Improve performance and stability, DataRobot recommends:

* Using a protected YARN queue to prevent preemption of containers
* Enabling ZooKeeper High Availability (HA)

### Memory and Compute Requirements

* Set `yarn.nodemanager.resource.memory-mb` to at least 60GB.
* Set `yarn.scheduler.maximum-allocation-mb` to at least 60GB.
* Set `yarn.nodemanager.resource.cpu-vcores` to at least 4 vcores.
* Set `yarn.scheduler.maximum-allocation-vcores` to at least 8 vcores.
* DataRobot worker nodes must have a minimum of 128GB of memory.

### Hadoop Container Requirements

| Container name | Max Instances allowed | Persistent count | vCores per instance | Memory per instance (GB) | Long Running | Notes |
|----------------|:---------------------:|:----------------:|:-------------------:|:------------------------:|:------------:|-------|
|DataRobot Master YARN AM|1|1|1|2|Y|Required|
|Modeling containers|8|0|8|60|N|Required|
|EDA containers|8|0|2|60|N|Required|
|DataRobot Master|NA|2|2|4|Y|Taking the role of different DSS and next steps tasks.|

{% block optional_scalable_ingest_requirements %}
#### Optional Scalable Ingest Requirements

| Container name | Max Instances allowed | Persistent count | vCores per instance | Memory per instance (GB) | Long Running | Notes |
|----------------|:---------------------:|:----------------:|:-------------------:|:------------------------:|:------------:|-------|
|ETL Controller|NA|1|1|1|Y|A lightweight service running outside of YARN: Track status/health of the services, Provide REST API to ETL services, Dataset type & format recognition.|
|ETL Default Worker Daemon|NA|1|1|1|Y|A new Spark app is dynamically created that submits and manages the qualifying ingest/downsampling in a new Yarn app per job request.|
|ETL Default Worker Spark Application|NA|0|26|77 (across all containers)|N|Executes jobs submitted to ETL Default Worker Daemon|


| Instance / Service name | ETL Default Worker Resources requirements |
|-------------------------|-------------------------------------------|
|Service requirements|1GB of RAM|
|Spark Application Master requirements|1GB of RAM + 1 CPU core|
|Spark Driver requirements|2GB of RAM + 1 CPU core|
|Spark Executor requirements|3GB of RAM + 2 CPU core|
{% endblock %}

## Cloudera Requirements

* Cloudera CDH must be version 5.4 or greater. CDH 6.1 support was added in 5.1.
* Cloudera cluster must be running on CentOS/RHEL version 6.4 or greater on the X86_64 Architecture.

### Required files

| Description | Filename | Notes |
|:------------|:---------|:------|
| Hadoop Parcel | `parcel/DataRobot-6.x.x-RELEASE-any.parcel` | Rename the file by replacing `any` with **el7** for CentOS/RHEL 7.x. Rename the file by replacing `any` with **el6** for CentOS/RHEL 6.4. |
| Hadoop Parcel Checksum | `parcel/DataRobot-6.x.x-RELEASE-any.parcel.sha` | Rename the file by replacing `any` with **el7** for CentOS/RHEL 7.x. Rename the file by replacing `any` with **el6** for CentOS/RHEL 6.4. |
| Custom Service Descriptor (CSD) | `csd/DataRobot-6.x.x-RELEASE.jar` | Configuration files used to integrate DataRobot with Cloudera. |

{% block ambari_requirements %}
## Ambari Requirements

* The DataRobot Platform support Hortonworks Data Platform (HDP) versions 2.3, 2.4, 2.5, 2.6, and 3.0.
* Ambari cluster must be running on CentOS/RHEL version 6.4 or greater on the X86_64 Architecture.

### Required files

| Description | Filename | Notes |
|:------------|:---------|:------|
| Hadoop Parcel | `parcel/DataRobot-6.x.x-RELEASE-any.parcel` | |
| Hadoop Parcel Checksum | `parcel/DataRobot-6.x.x-RELEASE-any.parcel.sha` | |
| Service Descriptor | `ambari/datarobot-ambari-5.2.2-RELEASE.tar.gz` | Configuration files used to integrate DataRobot with Ambari. |
{% endblock %}
