# Kerberos Integration

## Additional Configuration for Clusters With Kerberos Enabled

Skip this section if your cluster does not have Kerberos enabled.

The steps in this section are required to configure clusters with Kerberos enabled to work with the DataRobot application.
To begin, log in to your Cloudera Manager.

* Click the name of the **YARN** service on the left side of the screen.

* Click **Configuration** in the menu.

* Type `allowed.system.users` in the search field near the top-left of the screen.

* Click the add (+) button that appears lowest in the list of Allowed System Users and type datarobot in the text field that just appeared:

<img src="images/cdh-kerberos-user-add.png" alt="system users" style="border: 1px solid black;"/>

* Click **Save Changes** just above the **Allowed System Users** section.

* Scroll to the top of the screen and click the **Cloudera Manager** logo in the top-left corner of the page.

* Click on the name of the **HDFS** service in the panel on the left side of the scree

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

* Click **Save Changes** just above the text box.

* Click the **Cloudera Manager** logo at the top-left corner of the page.

* Click the topmost power button below your cluster's name.

* Click **Restart Stale Services** in the top-right corner of the screen.

* Confirm that *Re-deploy client configuration* is checked.

* Click **Restart Now** at the bottom of the screen.
**WARNING**: This will restart all services on your cluster.

* Once the restart command has completed successfully, click **Finish**.

You have now completed the additional requirements for environments with Kerberos enabled.
