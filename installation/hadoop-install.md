# Hadoop Installation Instructions {#hadoop-install}
DataRobot can integrate with Cloudera, Hortonworks, and IBM BigInsights Hadoop distributions.

## Create Config Files
To enable this integration, first create `hadoop-configuration.yaml` and `config.yaml`.

### hadoop-configuration.yaml
Place a file like the following in `/opt/DataRobot-3.1.x/`
```yaml
# FILE: hadoop-configuration.yaml
---
cluster_name: <name of hadoop cluster>
manager_address: <address of Ambari or Cloudera Manager>
# Set these to true if the Cloudera Manager or Ambari is using SSL
use_tls: false
ignore_ca: false
```

### config.yaml
Copy a sample YAML configuration file to `/opt/DataRobot-3.1.x/config.yaml`.
You can find a sample Cloudera `config.yaml` file in `example-configs/multi-node.hadoop.yaml`.  
Modify the sample to suit your environment.

Contact DataRobot support for help with this file.

## Hadoop Installation
Now, use the following sections install DataRobot on Hadoop.

* [Cloudera Installation](./cloudera-install.md)
* [Hortonworks/BigInsights Installation](./ambari-install.md)

