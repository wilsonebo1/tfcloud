# Hadoop KMS Integration

## Additional Configuration for Clusters With Kerberos Enabled

[**Hadoop KMS**](https://hadoop.apache.org/docs/stable/hadoop-kms/index.html) is a cryptographic key management server based on Hadoop’s KeyProvider API.

* Add to kms-site.xml next properties:

```xml
# CONFIG VALUE: core-site.xml
<property>
  <name>hadoop.kms.proxyuser.datarobot.hosts</name>
  <value>*</value>
</property>
<property>
  <name>hadoop.kms.proxyuser.datarobot.groups</name>
  <value>*</value>
</property>
```

* Set DataRobot conf `KMS_AUTHENTICATION_TYPE` and `hdfs.KMS_AUTHENTICATION_TYPE` to `kerberos`
* Set DataRobot conf `hdfs.KMS_PROVIDER` to `kms://http@KMS_HOST:16000/kms` 
