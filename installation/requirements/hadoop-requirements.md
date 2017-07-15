# DataRobot Hadoop Integration Requirements

DataRobot can integrate with Cloudera, Hortonworks, and IBM BigInsights Hadoop distributions.

## Access Requirements
The administrator must have permission to access the Cloudera Manager or Ambari via SSH and perform superuser actions such as moving files, changing permissions, and restarting services.

## Hadoop Requirements
* For Java 7 systems, Oracle Java JDK version greater than or equal to `1.7.0_75` must be installed.
* For Java 8 systems, Oracle Java JDK version greater than or equal to `1.8.0_60` must be installed.
* HDFS, Yarn, Spark on Yarn and ZooKeeper must be installed.
* The fully qualified domain name (FQDN) or IP address of the Cloudera Manager or Ambari server must be known.
* Set `yarn.nodemanager.resource.memory-mb` to at least 60GB.
* Set `yarn.scheduler.maximum-allocation-mb` to at least 60GB.
* Set `yarn.nodemanager.resource.cpu-vcores` to at least 4.
* Set `yarn.scheduler.maximum-allocation-vcores` to at least 4.
* DataRobot worker nodes must have a minimum of 128GB of memory.

## Cloudera Requirements
* Cloudera CDH must be version 5.4 through 5.11.
* Cloudera CDH must be running on CentOS/RHEL version 6.4 or greater.
* The /tmp directory on the Cloudera Manager must be writable and have 5GB of available space.

## Required files
| Description | Filename | Notes |
|:------------|:---------|:------|
| Cloudera Parcel | `DataRobot-3.1.x-el7.parcel`, `DataRobot-3.1.x-el7.parcel.sha` *or* `DataRobot-3.1.x-el6.parcel`, `DataRobot-3.1.x-el6.parcel.sha` | Use the file ending in **el7.parcel** for CentOS/RHEL 7.x.  Use the file ending in **el6.parcel** for CentOS/RHEL 6.4. |
| Custom Service Descriptor (CSD) | DataRobot-3.1.x.jar | Configuration files used to integrate an add-on service. |
