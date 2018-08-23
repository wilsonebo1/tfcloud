## Background

DataRobot depends on Cloudera Manager or Ambari to manage its configuration.
Installing DataRobot on a cluster that does not have one of these managers (referred to as unmanaged Hadoop) will require some additional steps. 
This guide provides an overview of the steps which are required to install DataRobot on an unmanaged Hadoop cluster.

The installation process consists of the following steps:
1. Distribute DataRobot code within the Hadoop cluster
2. Create `datarobot` user on all Hadoop instances
3. Adjust cluster settings
4. Create configuration files and environment variables
5. Launch the service

Installation of DataRobot on an unmanaged Hadoop cluster is not officially supported and not well tested.
It should be used only when other options are not available.
