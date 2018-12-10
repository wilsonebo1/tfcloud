# Hadoop HttpFS

## Additional Configuration for HttpFS

[**HttpFS**](http://hadoop.apache.org/docs/stable/hadoop-hdfs-httpfs/index.html) is a REST HTTP gateway supporting all HDFS file system operations and is interoperable with the webhdfs REST HTTP API.

To use DataRobot with HttpFS, enable the following properties in your cluster's `httpfs-site.xml` file.

```xml
<property>
  <name>httpfs.proxyuser.datarobot.hosts</name>
  <value>*</value>
</property>
<property>
  <name>httpfs.proxyuser.datarobot.groups</name>
  <value>*</value>
</property>
<property>
  <name>httpfs.proxyuser.datarobot.users</name>
  <value>*</value>
</property>
```

Next, configure DataRobot with the following properties:

* Check `PREFER_HTTPFS`.
* set `HTTPFS_HOST` to `http(s)://hostname:14000` or your HttpFS load balancer.

## Loadbalanced HTTPFS

When httpfs is loadbalanced, e.g. you have multiple httpfs servers behind one name you should set `HTTPFS_HOST` to the loadbalancer hostname and set `SECURITY_CONTAINER_USE_DELEGATION_TOKENS` to `False`.

## Delegation tokens

You can use `SECURITY_CONTAINER_USE_DELEGATION_TOKENS` setting in cloudera manager/ambari to change if DataRobot will use delegation tokens to access httpfs. 
By setting the mentioned setting to `False` you can disable delegation tokens and use plain kerberos auth.


