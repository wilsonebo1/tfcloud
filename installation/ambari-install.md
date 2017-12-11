# Ambari (Hortonworks/BigInsights) Installation

## Transfer Files from Edgenode to Ambari

Connect to the edge node via SSH:

```bash
ssh [USERNAME]@[EDGE NODE IP ADDRESS]
```

Transfer the installation files from the edge node to the Ambari Manager:

```bash
scp ~/hadoop/datarobot-ambari-*.tar.gz \
.  [AMBARI MANAGER SERVER IP ADDRESS]:/tmp
```

## Configure DataRobot Service for Ambari

Connect to the Ambari Manager Server via SSH:

```bash
ssh [USERNAME]@[AMBARI MANAGER IP ADDRESS]
```

Extract Ambari configuration descriptor:

```bash
cd /tmp
tar xvf datarobot-ambari-*.tar.gz
```

Copy Ambari configuration descriptor to services directories:

```bash
find /var/lib/ambari-server/resources/stacks/*/*/services -maxdepth 0 \
    | xargs -n 1 cp -r DATAROBOT
```

Add to `/var/lib/ambari-server/resources/stacks/*/*/role_command_order.json`:

```bash
"DATAROBOT_CLIENT-INSTALL": ["NAMENODE-START", "DATANODE-START"],
```

Restart Ambari server with:

```bash
sudo service ambari-server restart
```

If that fails, restart the service directly:

```bash
sudo ambari-server start --skip-database-check
```

The restart process may require several minutes to complete.

## Login to Ambari

You should now be able to log in to the Ambari UI in your web browser.

1. Go to the Ambari UI in your web browser. The UI is available on port 8080.
2. Enter your username and password, then click **Sign in**:
<img src="images/ambari-sign-in.png" alt="" style="border: 1px solid black;"/>

## Provide Additional Configuration

1. Go to the _MapReduce_ service:
<img src="images/ambari-mapreduce-service.png" alt="" style="border: 1px solid black;"/>
2. Navigate to the configuration:
<img src="images/ambari-navigation-config.png" alt="" style="border: 1px solid black;"/>

3. Append to the `mapreduce.application.classpath` parameter:
  * Using BigInsights: `:/usr/iop/current/hadoop-mapreduce-client/*`
  * Using Hortonworks: `:/usr/hdp/current/hadoop-mapreduce-client/*`

4. Save changes:
<img src="images/ambari-save-changes.png" alt="" style="border: 1px solid black;"/>

5. Update proxy-user settings in core-site.xml

DataRobot requires proxy-user settings in both secure (= Kerberos enabled) and nonsecure clusters.

5.1. Select the HDFS service:
<img src="images/ambari-hdfs-service.png" alt="" style="border: 1px solid black;"/>

5.2. Navigate to the configurations via the Configs tab:
<img src="images/ambari-hdfs-config.png" alt="" style="border: 1px solid black;"/>

5.3. Select the Advanced tab:
<img src="images/ambari-hdfs-advanced.png" alt="" style="border: 1px solid black;"/>

5.4. Expand the "Custom core-site" option:
<img src="images/ambari-hdfs-custom.png" alt="" style="border: 1px solid black;"/>

5.5. At the bottom of the window, click the "Add property..." link.

5.6. Click the bulk property icon in the right of the "Add Property" window:
<img src="images/ambari-hdfs-bulk-props.png" alt="" style="border: 1px solid black;"/>

5.7. In the "Properties" box, add proxyuser properties for DataRobot:

```bash
hadoop.proxyuser.datarobot.groups=*
hadoop.proxyuser.datarobot.hosts=*
```

Adding the above properties enables DataRobot to impersonate any user. These permissions can be narrowed, if needed, but DataRobot must be in the list. 

5.8. (Optional) Add proxyuser properties for YARN:

In nonsecure clusters without the Linux Container Executor setup, you also need to allow the YARN user to proxy DataRobot.

```bash
hadoop.proxyuser.yarn.groups=datarobot
hadoop.proxyuser.yarn.hosts=*
```

6. Save changes.


7. Restart all required services:
<img src="images/ambari-restart-services.png" alt="" style="border: 1px solid black;"/>

## Distribute Parcel to Hosts

There are a few different possibilities for distributing parcel to hosts.
Either `scp` the file to all hosts, or run a small webserver.

### Copying Parcel to All Hosts

For each host in Ambari that could run DataRobot service, copy the parcel
from edgenode to that host:

```bash
scp ~/hadoop/DataRobot-*.{parcel,parcel.sha} \
    [AMBARI HOST IP ADDRESS]:/tmp
```

In this case, the parcel URL used will look like:

```
file:////tmp/DataRobot-[PARCEL VERSION].parcel
```

### Run Temporary Webserver

Alternatively, a simple HTTP webserver on an edgenode can host the parcel.
For example:

```bash
cd [PATH TO DIRECTORY WITH PARCEL IN IT]
python -m SimpleHTTPServer [SERVER PORT]
```

**NOTE**: If `[SERVER PORT]` is not provided it will bind to port `8000`.

In this case, the parcel URL used will look like:

```
http://[IP OF SIMPLE WEBSERVER]:[SERVER PORT]/DataRobot-[PARCEL VERSION].parcel
```

**NOTE**: If using this approach, the edgenode must allow incoming traffic on `[SERVER PORT]`
from the Cloudera hosts.

## Install DataRobot Service

1. Click on **actions** and then **add service**:
<img src="images/ambari-add-service.png" alt="" style="border: 1px solid black;"/>
2. Select DataRobot for installation:
<img src="images/ambari-select-datarobot.png" alt="" style="border: 1px solid black;"/>
3. Click **Next**.
4. Select where to install DataRobot Master and click **Next**.
5. Select all YARN nodes as clients and click **Next**:
<img src="images/ambari-select-yarn.png" alt="" style="border: 1px solid black;"/>
6. Provide the URL to the parcel package in the `datarobot-env` configuration:
<img src="images/ambari-parcel-url.png" alt="" style="border: 1px solid black;"/>
7. Set up all required parameters and provide the license in the `datarobot-master`
configuration:
<img src="images/ambari-required-params.png" alt="" style="border: 1px solid black;"/>
3. Click **Next**.
4. In case if cluster is secured by Kerberos, provide credentials:
<img src="images/ambari-kerberos.png" alt="" style="border: 1px solid black;"/>
5. Proceed to the installation.

## Synchronize Configuration

Continue by [Synchronizing Configuration](./hadoop-install.md#synchronize-configuration)
