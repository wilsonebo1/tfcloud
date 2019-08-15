<a name="manage-installed-platform"></a>
# Manage the Cluster

This chapter presents administrative tasks to ensure the cluster is configured and operating as expected. For a reference to the API calls for monitoring the health of a DataRobot deployed cluster, see the [DataRobot Monitoring Guide.](https://support.datarobot.com/hc/en-us/articles/360029178711-Enterprise-Monitoring-Guide-v5-0-2-) Other deployment administration information can be found in [DataRobot Support articles.](https://support.datarobot.com/hc/en-us/categories/200185850-Frequently-Asked-Questions)

<a name="starting-stopping-and-managing-services"></a>
## Starting, stopping, and managing services
-----------------------------------------
To troubleshoot issues and make changes to the cluster, you need to know how to start, stop, and manage the various services. This section explains how to manage services for Docker; services for the Hadoop site are not addressed.

<a name="starting-services"></a>
###Starting services

Command name: `./bin/datarobot services start`

This is the initial start command. You execute this cluster-wide command from the provisioner host, under the same directory as `config.yaml` This command starts the registry and docker container services for all of the hosts from that file.


<a name="stopping-services"></a>
###Stopping services
Command name: `./bin/datarobot services stop`

Use this command to stop DataRobot. You execute this cluster-wide command from the provisioner host, under the same directory as `config.yaml`.  This command stops the registry and the docker containers cleanly, for all of the hosts from that file.


<a name="restart-services"></a>
###Restarting services:
Command name: `./bin/datarobot services restart`

Use this command to restart DataRobot when it is stopped. You execute this cluster-wide command from the provisioner host, under the same directory as `config.yaml`. Running this command runs the `datarobot services stop` command and then the `datarobot services start` command.

<a name="check-services-status"></a>
###Checking services' status:

Command name: `./bin/datarobot health cluster-checks`

This command checks the container state on docker, which is defined in the `config.yaml` file.

Docker easily deploys the application inside the container, which can provide the same isolation as with virtual machines (VM), but at a fraction of the computation power. It is beneficial to check on the container state to ensure that the deployment goes well. The services (Redis, Mongo, Gluster, HDFS, and Bucket/Blob storage) may fail to restart if the container isn’t cleanly stopped. If this is the case, you'll need to reboot the server.

DataRobot uses dependency delivery through Docker-run Mongo, which pulls Mongo from docker.io and starts it. It also creates a local registry. Images are loaded to the registry, and then pulled during the install.
