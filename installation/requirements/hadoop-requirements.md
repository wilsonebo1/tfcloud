# DataRobot Hadoop Integration Requirements

DataRobot is installable as a parcel that can run on your organization's
Hadoop cluster.

DataRobot can integrate with Cloudera, and Hortonworks Hadoop distributions.

**NOTE**: DataRobot supports only parcels as a format of software distribution for a Cloudera Hadoop cluster.
Deployment via system specific packages (RPM, DEB, etc.) is not supported.

## Access Requirements

The administrator must have permission to access the Cloudera or Ambari Manager
via SSH and perform superuser actions such as moving files, installing packages,
changing permissions, and restarting services.

## Hadoop Requirements

* For Java 8 systems, Oracle Java JDK version greater than or equal to
`1.8.0_60` must be installed.
* HDFS, Yarn, Spark on Yarn, and ZooKeeper must be installed.
* The fully qualified domain name (FQDN) or IP address of the Cloudera or Ambari
Manager server must be known.
* The /tmp directory on the Cloudera or Ambari Manager must be writable and have
at least 5GB of available space.
* If [Transparent Encryption in HDFS](http://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/TransparentEncryption.html) is enabled, [HttpFS](https://hadoop.apache.org/docs/stable/hadoop-kms/index.html) is required.

### Memory and Compute Requirements

* Set `yarn.nodemanager.resource.memory-mb` to at least 60GB.
* Set `yarn.scheduler.maximum-allocation-mb` to at least 60GB.
* Set `yarn.nodemanager.resource.cpu-vcores` to at least 4 vcores.
* Set `yarn.scheduler.maximum-allocation-vcores` to at least 4 vcores.
* DataRobot worker nodes must have a minimum of 128GB of memory.

## Cloudera Requirements

* Cloudera CDH must be version 5.4 or greater.
* Cloudera cluster must be running on CentOS/RHEL version 6.4 or greater on the X86_64 Architecture.

### Required files

| Description | Filename | Notes |
|:------------|:---------|:------|
| Hadoop Parcel | `DataRobot-4.2.x-el7.parcel` *or* `DataRobot-4.2.x-el6.parcel` | Use the file with **el7** for CentOS/RHEL 7.x. Use the file with **el6** for CentOS/RHEL 6.4. |
| Hadoop Parcel Checksum | `DataRobot-4.2.x-el7.parcel.sha` *or* `DataRobot-4.2.x-el6.parcel.sha` | Use the file with **el7** for CentOS/RHEL 7.x. Use the file with **el6** for CentOS/RHEL 6.4. |
| Custom Service Descriptor (CSD) | DataRobot-4.2.x.jar | Configuration files used to integrate DataRobot with Cloudera. |

## Ambari Requirements

* If your cluster is based on Hortonworks, it must be version 2.3, 2.4, 2.5 or 2.6.
* Ambari cluster must be running on CentOS/RHEL version 6.4 or greater on the X86_64 Architecture.

### Required files

| Description | Filename | Notes |
|:------------|:---------|:------|
| Hadoop Parcel | `DataRobot-4.2.x-el7.parcel` | |
| Hadoop Parcel Checksum | `DataRobot-4.2.x-el7.parcel.sha` | |
| Service Descriptor | datarobot-ambari-4.2.x.tar.gz | Configuration files used to integrate DataRobot with Ambari. |
