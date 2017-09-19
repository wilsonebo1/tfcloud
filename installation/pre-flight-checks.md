# Pre-Flight Checks

The following checks are useful for verifying that your cluster is ready to install and run the DataRobot application.
They will prevent the most common installation issues and are also good for troubleshooting issues with your configuration.

Perform these steps after performing the [Cluster Preparation](standard-install.md#linux-prep) section of the installation (after `make bootstrap-cluster`) and before performing the [Install and Configure the Application](standard-install.md#linux-provision) steps (before `make provision`).

## Docker storage capacity

Verify that Docker has sufficient available storage capacity by checking the output of:

```bash
docker info | grep 'Data Space' 2> /dev/null
```
Ensure that the difference between Data Space Total and Data Space Used is greater than 100 GB.

    Note: Data Space Used and Available may not add up to Total; this is expected in setups using devicemapper storage.

## Can you run Docker containers?

Verify that you can run Docker containers with the following command:

```bash
sudo su druser
cd /opt/DataRobot-3.1.x/
docker load -i dockerfiles/datarobot/saved/docker-registry.tar
docker run --rm -it docker.hq.datarobot.com/datarobot/registry
# You should see some logs from the container
# Hit Ctrl-C to cancel
```

## Provisioner connectivity

On the install node, logged in as the DataRobot user, run the following to verify the provisioner will be able to connect to all nodes in the cluster:

```bash
sudo su druser
cd /opt/DataRobot-3.1.x/
make provision-prompt
./inventory/hosts --list
ansible -i inventory/hosts -m shell -a 'uptime' all -vvvv
```

## Docker access across all nodes

This end-to-end test will verify that the provisioner can run, connect to nodes via SSH, and interact with the Docker daemon on all application servers:

```bash
sudo su druser
cd /opt/DataRobot-3.1.x/
make provision-prompt
ansible -i inventory/hosts -m docker -a "image=foo name=bar state=absent" all
```

## Logging

To verify that logging has been set up properly, run the following commands to generate test messages on your servers.
These commands can be run on any server for which you want to verify your logging setup.
Each command should generate a message in a file on the host’s configured logs directory (eg. `/opt/datarobot/logs/nginx.log`) and in the same file on the central rsyslog server (if applicable):

```bash
logger -i -p daemon.info DRJSON Test Logging Message
logger -i -p daemon.info DSSJSON Test Logging Message
logger -i -p daemon.info DRMJSON Test Logging Message
logger -i -p daemon.info NGINXJSONLOGS Test Logging Message
logger -i -p daemon.info DRAUDIT-gon0DRO4Pb Test Logging Message
ls -l /opt/datarobot/logs
```

**NOTE**: DataRobot does not automatically set up permissions for your RSYSLOG logging system, so the log files may be owned by root and they may not be world-readable.
Log file permissions can be modified in the RSYSLOG configuration files of each host.
If desired, put the `$FileOwner`, `$FileGroup`, and/or `$FileCreateMode` directives at  the top of your DataRobot RSYSLOG configuration file.

```
# FILE SNIPPET: /etc/rsyslog.d/53-logging.conf
$FileOwner druser
$FileGroup druser
$FileCreateMode 0600
...
```

To apply changes to log file permissions, remove the existing log files and restart the RSYSLOG daemon, or use chmod and chown as appropriate.

Note also that the file creation directives will affect RSYSLOG behavior in all files in /etc/rsyslog.d/ alphabetically higher than the DataRobot configuration.
If such files exist, review their contents and consider adding additional directives to reset permissions.

## Logrotate

Verify that logrotate is properly configured by forcing a rotation of the log files you just created:

```bash
$ ls /opt/datarobot/logs
all.log    datarobot.log         hadoop-master.log
audit.log  datasets-service.log  nginx.log
$ sudo logrotate -f /etc/logrotate.d/datarobot
$ ls /opt/datarobot/logs
all.log         datarobot.log              hadoop-master.log
all.log.1.gz    datarobot.log.1.gz         hadoop-master.log.1.gz
audit.log       datasets-service.log       nginx.log
audit.log.1.gz  datasets-service.log.1.gz  nginx.log.1.gz
...
$ sudo logrotate -f /etc/logrotate.d/rsyslog  # or equivalent file
$ ls /var/log
syslog          daemon.log              messages
syslog.1.gz     daemon.log.1.gz         messages.1.gz
...
```

**NOTE**: DataRobot logs are written to the `daemon` syslog facility. Review your system’s RSYSLOG configuration (`/etc/rsyslog.conf` and `/etc/rsyslog.conf.d/`) to see if these messages will end up in any other log file, such as `/var/log/daemon.log` or `/var/log/messages`, and adjust your RSYSLOG and logrotate configuration to handle these messages.

Example:

```
# FILE: /etc/logrotate.d/system
/var/log/daemon.log
/var/log/messages
/var/log/syslog
{
    su root root
    daily
    rotate 30
    copytruncate
    compress
    missingok
    notifempty
}
```

## Hadoop pre-flight checks

1. Check health and configuration issues reported by Cloudera Manager or Ambari (requires to update configuration and restart hadoop services):

**CDH**:

<img src="images/cdh-health-check.png" alt="" style="border: 1px solid black;"/>

**HDP**:

<img src="images/ambari-config-issues.png" alt="" style="border: 1px solid black;"/>

2. Make sure datarobot user can submit yarn applications with required container sizes (you can vary `container_memory`, `num_containers`, `container_vcores` parameters, e.g. to run on every NM set this values close to `yarn.scheduler.maximum-allocation-{mb,vcores}`):

**CDH**:

```
yarn jar \
/opt/cloudera/parcels/CDH/lib/hadoop-yarn/hadoop-yarn-applications-distributedshell.jar \
-shell_command "hdfs dfs -ls /tmp" \
-debug -appname "DataRobot pre-flight check" \
-num_containers 3 -container_memory 60000 -container_vcores 4 \
-jar /opt/cloudera/parcels/CDH/lib/hadoop-yarn/hadoop-yarn-applications-distributedshell.jar
```

**HDP**:

```
yarn jar \
/usr/hdp/current/hadoop-yarn-client/hadoop-yarn-applications-distributedshell.jar \
-shell_command "hdfs dfs -ls /tmp" \
-debug -appname "DataRobot pre-flight check" \
-num_containers 3 -container_memory 60000 -container_vcores 4 \
-jar /usr/hdp/current/hadoop-yarn-client/hadoop-yarn-applications-distributedshell.jar 
```

3. Make sure `datarobot` user can impersonate unix user for ldap/impersonation environment:
`curl -i --negotiate -u : "http://<HOST>:<PORT>/webhdfs/v1/<PATH>?doas=<USER>&op=LISTSTATUS"`

e.g.
`curl -i --negotiate -u : "http://bos-rd1-cdh-master1.rd1.hq.datarobot.com:50070/webhdfs/v1/tmp?doas=peter&op=LISTSTATUS"`

4. Make sure Spark is installed and functioning:

**CDH**:

```
spark-submit --master yarn \
--num-executors 3 --executor-memory 20g --executor-cores 4 \
--proxy-user PROXY_USER \
--class org.apache.spark.examples.SparkPi \
/opt/cloudera/parcels/CDH/lib/spark/lib/spark-examples.jar 10000
```

**HDP**:

```
spark-submit --master yarn \
--num-executors 3 --executor-memory 20g --executor-cores 4 \
--proxy-user PROXY_USER \
--class org.apache.spark.examples.SparkPi \
/usr/hdp/current/spark-client/lib/spark-examples-1.6.2.2.5.3.0-37-hadoop2.7.3.2.5.3.0-37.jar 10000
```
