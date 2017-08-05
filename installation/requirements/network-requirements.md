# DataRobot Network Access Requirements

## End User

End User and Administrator Access to web server and prediction nodes for web UI and API clients.

| Port  | Protocol | Component|
|------:|:---------|:---------|
| 80    | TCP      | Web Server HTTP Traffic (SSL Not Enabled) |
| 443   | TCP      | Web Server HTTPS Traffic Enabled |

## Administrator

Administrator Access to all nodes.

| Port  | Protocol | Component|
|------:|:---------|:---------|
| 22    | TCP      | SSH Access |


## Internal Ports

The following ports must be opened between all Linux nodes in the
application server cluster, whether or not using Hadoop.

| Port  | Protocol | Component |
|------:|:---------|:----------|
| 80    | TCP      | NGINX     |
| 443   | TCP      | NGINX     |
| 1514  | UDP      | Logging   |
| 3000  | TCP      | DataRobot Prediction Optimization User Interface |
| 5000  | TCP      | Docker Registry   |
| 5445  | TCP      | IDE Client Broker |
| 5446  | TCP      | IDE Client Worker |
| 5544  | UDP      | Audit Logs |
| 6379  | TCP      | Redis |
| 6556  | TCP      | Resource Proxy Subscriber |
| 6557  | TCP      | Resource Proxy Publisher |
| 6558  | TCP      | Queue Proxy Subscriber |
| 6559  | TCP      | Queue Proxy Publisher |
| 8000  | TCP      | DataRobot Flask Application |
| 8001  | TCP      | DataRobot v0 API |
| 8002  | TCP      | DataRobot v1 API |
| 8004  | TCP      | DataRobot v2 API |
| 8011  | TCP      | DataRobot Socket.IO Server |
| 8023  | TCP      | DataRobot Upload Server |
| 8033  | TCP      | DataRobot Diagnostics Server |
| 8100  | TCP      | DataRobot Datasets Service API |
| 9000  | TCP      | DataRobot Prediction Optimization Application |
| 9090  | TCP      | DataRobot Availability Monitor |
| 9496  | TCP      | DataRobot PNGExport Service |
| 26379 | TCP      | Redis Sentinel |
| 27017 | TCP      | Mongo |

### Non-Hadoop Worker Ports

For non-Hadoop installs, additional internal ports are required for DataRobot workers.

| Port  | Protocol | Component |
|------:|:---------|:----------|
| 5555  | TCP      | Worker Broker Client |
| 5556  | TCP      | Worker Broker |
| 5558  | TCP      | User Worker Broker Client |
| 5559  | TCP      | User Worker Broker |

### Gluster Ports

If using `gluster` as a data backend, e.g. in non-Hadoop installs, additional
internal ports are required.

| Port  | Protocol | Component |
|------:|:---------|:----------|
| 111   | TCP/UDP  | Gluster Portmapper Service   |
| 24007 | TCP      | Gluster Daemon |
| 24008 | TCP      | Gluster Management |
| 24009 | TCP      | Gluster Brick |
| 49152 | TCP      | Gluster Brick |

## Hadoop Installations

**NOTE**: Default Hadoop ports are listed here.

_Check these settings on your cluster to ensure correct firewall configuration._

### Administrator Access

#### Cloudera

Administration ports necessary for Cloudera Manager.

| Port  | Protocol | Component|
|------:|:---------|:---------|
| 22    | TCP      | SSH Access |
| 7180  | TCP      | Cloudera Manager web interface |
| 7183  | TCP      | Cloudera Manager web interface (SSL enabled) |

#### Ambari

Administration ports necessary for Ambari Manager.

| Port  | Protocol | Component|
|------:|:---------|:---------|
| 22    | TCP      | SSH Access |
| 8080  | TCP      | Ambari Manager web interface |


### Communication Within the Hadoop Cluster

These ports are used to communicate from one Hadoop server
to another. All of these ports must be open on all Hadoop servers
from all other Hadoop servers. These ports do not need to be open
on application servers.

Some of these ports may be different depending on your Hadoop
configuration.

Example ports include:

| Port       | Protocol | Component|
|-----------:|:---------|:---------|
| 2888       | TCP      | Zookeeper Quorom Port |
| 3888       | TCP      | Zookeeper Election Port |
| 7182-7186  | TCP      | Cloudera Internal Communication |
| 7190-7191  | TCP/UDP  | Cloudera P2P Parcel Distribution |
| 8030-8050  | TCP      | YARN Ports |
| 8088       | TCP      | YARN ResourceManager HTTP |
| 8090       | TCP      | YARN ResourceManager HTTPs |

### Communication from Hadoop Cluster to Application Servers

These ports must be opened on all Hadoop servers from all application
servers.

| Port  | Protocol | Component|
|------:|:---------|:---------|
| 80    | TCP      | HTTP traffic for config sync (SSL not enabled on edge node) |
| 443   | TCP      | HTTPS traffic for config sync (SSL enabled on edge node) |
| 1514  | UDP      | Logging |
| 6379  | TCP      | Redis |
| 6556  | TCP      | Resource Proxy Subscriber |
| 6558  | TCP      | Queue Proxy Subscriber |
| 8027  | TCP      | Hadoop Configuration Sync |
| 8100  | TCP      | DataRobot DataSets Service API |
| 26379 | TCP      | Redis Sentinel |
| 27017 | TCP      | Mongo |

### Communication from Application Servers to the Hadoop Cluster

These ports must be opened on the application servers from all
Hadoop servers.

#### Common Ports

Both Cloudera and Ambari use these ports.

| Port  | Protocol | Hadoop Configuration Variable | Component |
|------:|:---------|:------------------------------|:----------|
| 2181  | TCP      | `clientPort`                  | ZooKeeper client port |
| 7680  | TCP      | Not configurable              | DataRobot Application Manager |
| 8020  | TCP      | `fs.default.name`, `fs.defaultFS` | NameNode IPC Port |
| 8027  | TCP      |                               | Hadoop Configuration Sync |
| 8485  | TCP      | `dfs.journalnode.rpc-address` | Required if using HA HDFS |
| 50020 | TCP      | `dfs.datanode.ipc.address` | HDFS Metadata operations |
| 50070 | TCP      | `dfs.namenode.http-address` | NameNode Web UI without HTTPS |
| 50090 | TCP      | `dfs.namenode.secondary.http-address` | Secondary NameNode without HTTPS |
| 50091 | TCP      | `dfs.namenode.secondary.https-address` | Secondary NameNode with HTTPS |
| 50470 | TCP      | `dfs.namenode.https-address`  | NameNode Web UI with HTTPS |
| 50475 | TCP      | `dfs.datanode.https.address`  | Data Transfer with HTTPS |

#### Additional Cloudera Ports

These ports are use by Cloudera in addition to the common ports.

| Port  | Protocol | Hadoop Configuration Variable | Component |
|------:|:---------|:------------------------------|:----------|
| 1004  | TCP      | `dfs.datanode.address` | Data transfer (HDFS HA) |
| 1006  | TCP      | `dfs.datanode.http.address`| Data transfer without HTTPS (HDFS HA) |
| 2552  | TCP      |                               | Cloudera Log Publisher |
| 7180  | TCP      |                               | Cloudera Manager web interface |
| 7183  | TCP      |                               | Cloudera Manager web interface (SSL enabled) |

#### Additional Ambari Ports

These ports are use by Ambari in addition to the common ports.

| Port  | Protocol | Hadoop Configuration Variable | Component |
|------:|:---------|:------------------------------|:----------|
| 1019  | TCP      | `dfs.datanode.address` | Data transfer (HDFS HA) |
| 1022  | TCP      | `dfs.datanode.http.address` | Data transfer without HTTPS (HDFS HA) |
| 8080  | TCP      |                             | Ambari Manager web interface |
| 50010 | TCP      | `dfs.datanode.address` | Data transfer |
| 50075 | TCP      | `dfs.datanode.http.address` | Data transfer without HTTPS |
