# Hadoop KMS Integration

## Additional Configuration for Clusters With Kerberos Enabled

[**Hadoop KMS**](https://hadoop.apache.org/docs/stable/hadoop-kms/index.html) is a cryptographic key management server based on Hadoop’s KeyProvider API.

To use DataRobot with Hadoop KMS, enable the following properties in your cluster's `kms-site.xml`

```xml
<property>
  <name>hadoop.kms.proxyuser.datarobot.hosts</name>
  <value>*</value>
</property>
<property>
  <name>hadoop.kms.proxyuser.datarobot.groups</name>
  <value>*</value>
</property>
<property>
  <name>hadoop.kms.proxyuser.datarobot.users</name>
  <value>*</value>
</property>
```

Next, configure DataRobot with the following properties:

* Set `KMS_AUTHENTICATION_TYPE` and `hdfs.KMS_AUTHENTICATION_TYPE` to `kerberos`.
* Set `hdfs.KMS_PROVIDER` to `kms://http@<KMS_HOST>:16000/kms` .
