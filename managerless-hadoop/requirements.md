## Cluster requirements

* Hadoop should be version `2.7.x` or `2.8.x`
* The DataRobot parcel should be distributed under a common arbitrary path.
    * The parcel should be unpacked into that directory
* `datarobot` user should be created on each node with the primary group `hadoop`.
* If Kerberos is enabled, a keytab should be created for the `datarobot` user
* Proxy users should be set in YARN's `core-site.xml`:
```
hadoop.proxyuser.datarobot.users    *
hadoop.proxyuser.datarobot.hosts    *
hadoop.proxyuser.datarobot.groups    *
allowed.system.users                    datarobot
```
* For unsecured hadoop - LCE should be set and it should be allowed to run
containers on behalf of any user. This can be configured by setting the following properties
in `yarn-site.xml`:
```
yarn.nodemanager.linux-container-executor.nonsecure-mode.limit-users    false
yarn.nodemanager.container-executor.class                            org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor
```
