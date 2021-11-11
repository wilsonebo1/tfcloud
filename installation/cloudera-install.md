# Cloudera Installation Instructions

Follow the steps in the sections below to install DataRobot on your Cloudera cluster.

## Prepare Cloudera Manager

* Connect to the application server via SSH:

```bash
ssh datarobot@[APPLICATION SERVER IP ADDRESS]
```

* Transfer the installation files from the application server to the Cloudera Manager server if it has not already been done:

```bash
scp ~/hadoop/DataRobot-RELEASE-hadoop-*.tar [CLOUDERA MANAGER SERVER IP ADDRESS]:/tmp
```

* Connect to the Cloudera Manager Server via SSH:

```bash
ssh [USERNAME]@[CLOUDERA MANAGER IP ADDRESS]
```

* Untar the hadoop install files:

```bash
tar xvf /tmp/DataRobot-RELEASE-hadoop-*.tar
```

* Move the CSD file:

```bash
sudo mv /tmp/csd/*.jar /opt/cloudera/csd/
```

* Change the ownership of the installation files:

```bash
sudo chown cloudera-scm:cloudera-scm /opt/cloudera/csd/DataRobot-*.jar
```

* Change the permissions of the installation file:

```bash
sudo chmod 644 /opt/cloudera/csd/DataRobot-*.jar
```

* Move the parcel file and the parcel sha file:

```bash
sudo mv /tmp/parcel/DataRobot-* /opt/cloudera/parcel-repo
```

* Rename the parcel file and the parcel sha file (you must replace _x_ with the appropriate release number):

For RHEL 7:

```bash
sudo mv /opt/cloudera/parcel-repo/DataRobot-7.x.x-RELEASE-any.parcel /opt/cloudera/parcel-repo/DataRobot-7.x.x-RELEASE-el7.parcel
sudo mv /opt/cloudera/parcel-repo/DataRobot-7.x.x-RELEASE-any.parcel.sha /opt/cloudera/parcel-repo/DataRobot-7.x.x-RELEASE-el7.parcel.sha
```

**NOTE**: The CDH 5.4.0 and 5.5.0 .sha files have different formats.

The CDH 5.4.0 format is `SHA PARCEL_FILENAME`:

```
# FILE: DataRobot-7.x.x-RELEASE-el7.parcel.sha
9304fab63aa02f6e3ebbb27fc1c46f7fdc551c3e DataRobot-7.x.x-RELEASE-el7.parcel
```

**NOTE**: This means you must add the filename to the sha file distributed with the DataRobot release

CDH 5.5.0 and later **must only contain the SHA**,
_without the space and filename_, for example:

```
# FILE: DataRobot-7.x.x-RELEASE-el7.parcel.sha
9304fab63aa02f6e3ebbb27fc1c46f7fdc551c3e
```

* Change the ownership of the parcel file and parcel sha file:

```bash
sudo chown cloudera-scm:cloudera-scm /opt/cloudera/parcel-repo/DataRobot-*
```

* Change permissions on the parcel file and parcel sha file:

```bash
sudo chmod 644 /opt/cloudera/parcel-repo/DataRobot-*
```

* Restart the Cloudera Manager Server:

```bash
sudo service cloudera-scm-server restart
```

The restart process may require several minutes to complete.

Even after **Starting cloudera-scm-server** is marked as complete in the terminal,
the Cloudera Manager UI will be unavailable until the restart process is fully
finished.

## Install DataRobot via Cloudera Manager

You should now be able to log in to the Cloudera Manager UI in your web browser.

* Go to the Cloudera Manager UI in your web browser.

The UI is available on port `7180` for HTTP or `7183` for HTTPS.
For example, access a Cloudera Manager with HTTPS enabled at `https://<Cloudera Manager>:7183`.

* Enter your username and password, then click **Login**.


### Update proxyuser settings in core-site.xml

DataRobot requires proxyuser settings in both secure (= Kerberos enabled) and nonsecure clusters.

* Click the name of the **YARN** service on the left side of the screen.

* Click **Configuration** in the menu.

* Type `allowed.system.users` in the search field near the top-left of the screen.

* Click the add (+) button that appears lowest in the list of Allowed System Users and type datarobot in the text field that just appeared:

<img src="special-topics/images/cdh-kerberos-user-add.png" alt="system users" style="border: 1px solid black;"/>

* Click **Save Changes** just above the **Allowed System Users** section.

* Scroll to the top of the screen and click the **Cloudera Manager** logo in the top-left corner of the page.

* Click on the name of the **HDFS** service in the panel on the left side of the screen.

* Click on **Configuration** in the menu.

* Type `Cluster-wide Advanced Configuration Snippet (Safety Valve) for core-site.xml` in the search field near the top-left of the screen.
Paste the following XML into the large text box:

```xml
# CONFIG VALUE: core-site.xml
<property>
  <name>hadoop.proxyuser.datarobot.hosts</name>
  <value>*</value>
</property>
<property>
  <name>hadoop.proxyuser.datarobot.groups</name>
  <value>*</value>
</property>
<property>
 <name>hadoop.proxyuser.datarobot.users</name>
 <value>*</value>
</property>
```

* (Optional) Add proxyuser properties for YARN. In nonsecure clusters without the Linux Container Executor (LCE) setup, you also need to allow the YARN user to proxy DataRobot.

```bash
hadoop.proxyuser.yarn.groups=datarobot
hadoop.proxyuser.yarn.users=datarobot
hadoop.proxyuser.yarn.hosts=*
```

* (Optional) If you want DataRobot to use [HttpFS](https://hadoop.apache.org/docs/stable/hadoop-kms/index.html) instead of [webhdfs](http://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/WebHDFS.html), add proxyuser properties for HttpFS as described [here](special-topics/httpfs.md).

* (Optional) If your secure cluster has a [Key Management Server (KMS)](https://hadoop.apache.org/docs/stable/hadoop-kms/index.html), add proxy user properties for KMS as described [here](special-topics/kms.md).

---
**NOTE**

In clusters without Kerberos authentication, by default, the LCE runs all jobs as user "nobody". This user can be changed by setting "yarn.nodemanager.linux-container-executor.nonsecure-mode.local-user" to the desired user. However, it can also be configured to run jobs as the user submitting the job. In that case "yarn.nodemanager.linux-container-executor.nonsecure-mode.limit-users" should be set to false. See [here](https://hadoop.apache.org/docs/r2.7.2/hadoop-yarn/hadoop-yarn-site/NodeManagerCgroups.html) for more detailed information.
DataRobot submits YARN applications from within a YARN container thus either the owner of the process needs to be the service user "datarobot" or the user owning the process needs to be able to proxy "datarobot". If this is not the case, the submitted YARN applications won't be owned by "datarobot".

If Kerberos is enabled, DataRobot needs to be able to run Spark jobs on behalf of the currently authenticated user, on any available Yarn host. This can be enabled by listing all Yarn worker hosts and all DataRobot users in the config file, or by using "*" for those properties.

---

---
**NOTE**

If you use [Transparent Encryption in HDFS](http://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/TransparentEncryption.html) you must use [HttpFS](special-topics/httpfs.md) instead of webhdfs.

---

* Click **Save Changes** just above the text box.

* Click the **Cloudera Manager** logo at the top-left corner of the page.

* Click the topmost power button below your cluster's name.

* Click **Restart Stale Services** in the top-right corner of the screen.

* Confirm that *Re-deploy client configuration* is checked.

* Click **Restart Now** at the bottom of the screen.
**WARNING**: This will restart all services on your cluster.

* Once the restart command has completed successfully, click **Finish**.

### Distribute and Activate the DataRobot Parcel

* Ensure that all YARN nodes have at least 25 GB of free space under
  `/opt/cloudera/parcels` for the DataRobot parcel contents.

* Click on the Parcels icon (<img src="./images/cdh-parcels-icon.png" alt="parcels icon" style="border: 1px solid black;"/>)
in the top toolbar of the website.

* Click on your cluster name on the left hand side in the **Location** section.
Search the list of parcels for the row labeled **DataRobot**:

<img src="./images/cdh-parcels.png" alt="CDH Parcels" style="border: 1px solid black;"/>

**Note**: If the **DataRobot** parcel does not show up on the list, follow the [instruction](./ambari-install.md#run-temporary-webserver) in Ambari installation to use temporary webserver to distribute the parcel via remote url.

* If the rightmost side of that row contains a button labeled **Download**,
click it and wait for the action to complete.

* Click the **Distribute** button on the rightmost side of the row for the
DataRobot parcel.

* Click the button again when its label says **Activate**.

* When asked **Are you sure?**, click **OK** and wait for activation to complete.
The Status column for the DataRobot parcel should now read **Distributed, Activated**.

* Scroll to the top of the screen and click the **Cloudera Manager** logo.

* Click the down arrow button to the right of your cluster's name.

* Click **Deploy Client Configuration**:

<img src="./images/cdh-deploy-client-config.png" alt="CDH Deploy Client Config" style="border: 1px solid black;"/>

**NOTE**: Some versions of Cloudera Manager do not have Deploy Client Configuration
in this dropdown menu. If you do not see it, deploy configuration for each service
individually by clicking the blue power icon next to its name and clicking through
the wizard.

* Click **Deploy Client Configuration** in the confirmation window.

* Wait for the client configuration to deploy.

* Once each step has a green checkmark to its left, click **Close**.

* Click the down arrow button to the right of your cluster's name and click **Restart**.

<img src="./images/cdh-restart.png" alt="CDH Restart" style="border: 1px solid black;"/>

* Click **Restart** in the confirmation window and wait for the command to
finish, then click **Close**.

The DataRobot Parcel is now distributed and activated and all service
configurations are updated.

Next, you will add dependencies for the DataRobot Service.

### Add the Spark Service

The DataRobot service requires that Spark be installed on your cluster.

Follow these instructions to add the Spark service.

* Click the down arrow button to the right of your cluster's name and
select **Add a Service**.

* Click on the radio button to select Spark (do *not* select the standalone
option) and click **Continue**:

<img src="./images/cdh-spark.png" alt="CDH Spark" style="border: 1px solid black;"/>

* Click **Continue** on the new screen.

* Wait while the system adds the Spark service.

* Click **Continue** when it finishes, then click **Finish** on the Congratulations page.

* Click the down arrow button to the right of your cluster's name and click **Restart** as before.

* Wait for the command to finish and click **Close**.

Spark is now installed on your cluster.

### Add the DataRobot Service

Next, install the DataRobot service on your cluster.

* Click the down arrow button to the right of your cluster's name and select **Add a Service**.

* Click the radio button labeled **DataRobot** and click **Continue**:

<img src="./images/cdh-datarobot-service.png" alt="CDH DataRobot Service" style="border: 1px solid black;"/>

* Click **Select a host** under the **DataRobot Master Service** label.

The master service is a process that runs on a Hadoop node and continuously checks if YARN is still running.

<img src="./images/cdh-dr-master-service.png" alt="CDH DataRobot Master Service" style="border: 1px solid black;"/>

* Click the name of the system to host the master service.

This service can go on any node, but we recommend that it go on a **NameNode**
or other administrative node rather than a worker.

<img src="./images/cdh-master-host-select.png" alt="CDH Master Host Select" style="border: 1px solid black;"/>

* Click **OK**.

* For all **DataRobot ETL** services, place one instance of each service on an
available DataNode using the same procedure.

**ETL** services work with Spark to enable large file ingest and processing up to 100GB.

* Click **OK** and **Continue**.

* Click in the **App Node Location** text field and key in the IP or DNS of application server. Example: http://10.0.0.1

* If custom Java Keystore or Truststore are used on your Hadoop cluster, please update **Custom Java key store's file**, **Custom Java trust store's file** to point to the CA certificate location, as depicted in the screenshot below

<img src="./images/java-opts.png" alt="Java Options to enable custom key store and trust store" style="border: 1px solid black;"/>

* For HA HDFS clusters, set the following (options not shown in screen above):
  - To explicitly pick an active namenode, fill in a value for the `ACTIVE_NAMENODE_ADDRESS` field. If not specified, DataRobot will automatically pick the active namenode.
  - If multiple nameservices exist, use the `NAMESERVICE` variable to specify the one you want DataRobot to use.

* For [HttpFS](https://hadoop.apache.org/docs/stable/hadoop-kms/index.html), set the following (options not shown in screen above):
  - Check the `PREFER_HTTPFS` field and fill in a value for `HTTPFS_HOST`, specifying the HttpFS destination (for example, 'https://hostname:14000').

* Click **Continue** and wait while DataRobot is added to the cluster.

* When the process is complete, click **Continue**.

* Click **Finish** on the congratulations page.

* Click the down arrow button to the right of your cluster's name and
select **Deploy Client Configuration**.

<img src="./images/cdh-deploy-client-config.png" alt="CDH Deploy Client Config" style="border: 1px solid black;"/>

* Click **Deploy Client Configuration** in the confirmation window.

* Wait for the client configuration to deploy.

* When each step has a green checkmark to its left, click **Close**.

* Click the down arrow button to the right of your cluster's name and select **Restart**.

* Once the restart command has completed successfully, click **Close**.

* If the DataRobot service fails to start, check the `stderr` logs in the
command results. If there was a configuration error, stop and then delete the
DataRobot service and try to add it again.

<img src="./images/cdh-dr-fail.png" alt="CDH DataRobot Fail" style="border: 1px solid black;"/>

* Click on the DataRobot service to see a status summary.

* The DataRobot Master Service should be marked in green, indicating "Good Health."

* Hosts should display "1 Good Health."

## Reconfigure

Finally, when you want to change configuration of the system, please follow the steps in [Reconfigure](./hadoop-install.md#reconfigure)
