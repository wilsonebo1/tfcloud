# DataRobot Network Access Requirements

**NOTE**: Unless otherwise specified, "Hadoop" is applicable to both Cloudera
and Ambari clusters. Where there is something specific to Cloudera or
Ambari, it is mentioned explicitly.

In Hadoop-based installs, the **"application servers"** are any edge-node
servers, running DataRobot services _outside of Hadoop_.


## End User

End User and Administrator Access to web server and prediction servers for
web UI and API clients.

```
End User => Webserver/Prediction Servers
Provisioner/Administration Server => Webserver/Prediction Servers
```

| Port  | Protocol | Component|
|------:|:---------|:---------|
| 80    | TCP      | Web Server HTTP Traffic (TLS Not Enabled) |
| 443   | TCP      | Web Server HTTPS Traffic Enabled |

## Administrator

All servers must allow incoming requests on these ports from an administration
server (e.g. "provisioner").

```
Provisioner/Administration Server => All Servers
```

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
| 8097  | TCP      | DataRobot Prediction Optimization Application |
| 8100  | TCP      | DataRobot Datasets Service API |
| 9090  | TCP      | DataRobot Availability Monitor |
| 9496  | TCP      | DataRobot PNGExport Service |
| 26379 | TCP      | Redis Sentinel |
| 27017 | TCP      | MongoDB |

### Non-Hadoop Worker Ports

For non-Hadoop installs, additional internal ports are required for
DataRobot workers.

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

These ports must be open on all Hadoop servers to allow incoming requests
from an administration server.

```
Provisioner/Administration Server => Hadoop Servers
```

#### Cloudera

Administration ports necessary for Cloudera Manager.

| Port  | Protocol | Component|
|------:|:---------|:---------|
| 22    | TCP      | SSH Access |
| 7180  | TCP      | Cloudera Manager web interface |
| 7183  | TCP      | Cloudera Manager web interface (TLS enabled) |

#### Ambari

Administration ports necessary for Ambari Manager.

| Port  | Protocol | Component|
|------:|:---------|:---------|
| 22    | TCP      | SSH Access |
| 8080  | TCP      | Ambari Manager web interface |


### Communication Within the Hadoop Cluster

These ports are used to communicate from one Hadoop server
to another. All of these ports must be open on all Hadoop servers
to allow incoming requests to all other Hadoop servers and allow
outgoing requests to all other Hadoop servers.

These ports do not need to be open on application servers.

```
Hadoop Servers <=> Hadoop Servers
```

Some of these ports may be different depending on your Hadoop
configuration.

Example ports include:

| Port       | Protocol | Component|
|-----------:|:---------|:---------|
| 2888       | TCP      | Zookeeper Quorom Port |
| 3888       | TCP      | Zookeeper Election Port |
| 8030-8050  | TCP      | YARN Ports |
| 8088       | TCP      | YARN ResourceManager HTTP |
| 8090       | TCP      | YARN ResourceManager HTTPs |


#### Additional Cloudera Ports

Cloudera installs require additional ports of communication within
the Hadoop cluster. Some of these ports may be different
depending on configuration in your Cloudera Manager.

Example ports include:

| Port       | Protocol | Component|
|-----------:|:---------|:---------|
| 7182-7186  | TCP      | Cloudera Internal Communication |
| 7190-7191  | TCP/UDP  | Cloudera P2P Parcel Distribution |

### Communication from Hadoop Cluster to Application Servers

These ports must be opened on all application servers to allow
incoming requests from all Hadoop servers. Hadoop servers must allow outgoing
requests on these ports to all application servers.

```
Hadoop Servers => Application Servers
```

| Port  | Protocol | Component|
|------:|:---------|:---------|
| 80    | TCP      | HTTP traffic for config sync (TLS not enabled on edge node) |
| 443   | TCP      | HTTPS traffic for config sync (TLS enabled on edge node) |
| 1514  | UDP      | Logging |
| 6379  | TCP      | Redis |
| 6556  | TCP      | Resource Proxy Subscriber |
| 6558  | TCP      | Queue Proxy Subscriber |
| 8027  | TCP      | Hadoop Configuration Sync |
| 8100  | TCP      | DataRobot DataSets Service API |
| 26379 | TCP      | Redis Sentinel |
| 27017 | TCP      | MongoDB |

### Communication from Application Servers to the Hadoop Cluster

These ports must be opened on all Hadoop servers to allow incoming
requests from all application servers. Application servers must
allow outgoing requests on these ports to all Hadoop servers.

```
Application Servers => Hadoop Servers
```

#### Common Ports

Both Cloudera and Ambari use these ports.

| Port  | Protocol | Hadoop Configuration Variable | Component |
|------:|:---------|:------------------------------|:----------|
| 2181  | TCP      | `clientPort`                  | ZooKeeper client port |
| 7680  | TCP      | Not configurable              | DataRobot Application Manager |
| 8020  | TCP      | `fs.default.name`, `fs.defaultFS` | NameNode IPC Port |
| 8027  | TCP      |                               | Hadoop Configuration Sync |
| 8485  | TCP      | `dfs.journalnode.rpc-address` | Required if using HA HDFS |
| 9001  | TCP      | Not configurable              | ETL Controller |
| 50020 | TCP      | `dfs.datanode.ipc.address` | HDFS Metadata operations |
| 50070 | TCP      | `dfs.namenode.http-address` | NameNode Web UI without HTTPS |
| 50090 | TCP      | `dfs.namenode.secondary.http-address` | Secondary NameNode without HTTPS |
| 50091 | TCP      | `dfs.namenode.secondary.https-address` | Secondary NameNode with HTTPS |
| 50470 | TCP      | `dfs.namenode.https-address`  | NameNode Web UI with HTTPS |
| 50475 | TCP      | `dfs.datanode.https.address`  | Data Transfer with HTTPS |


These ports are only used on DataRobot 4.2.1 and above.

| Port  | Protocol | Hadoop Configuration Variable | Component |
|------:|:---------|:------------------------------|:----------|
| 44011 | TCP      | Not configurable              | DataRobot YARN Application Master Stats |
| 44012 | TCP      | Not configurable              | DataRobot YARN Application Master Stats |
| 44013 | TCP      | Not configurable              | DataRobot YARN Application Master Stats |
| 44014 | TCP      | Not configurable              | DataRobot YARN Application Master Stats |
| 44015 | TCP      | Not configurable              | DataRobot YARN Application Master Stats |
| 44016 | TCP      | Not configurable              | DataRobot YARN Application Master Stats |

#### Additional Cloudera Ports

These ports are used by Cloudera in addition to the common ports.

| Port  | Protocol | Hadoop Configuration Variable | Component |
|------:|:---------|:------------------------------|:----------|
| 1004  | TCP      | `dfs.datanode.address` | Data transfer (HDFS HA) |
| 1006  | TCP      | `dfs.datanode.http.address`| Data transfer without HTTPS (HDFS HA) |
| 2552  | TCP      |                               | Cloudera Log Publisher |
| 7180  | TCP      |                               | Cloudera Manager web interface |
| 7183  | TCP      |                               | Cloudera Manager web interface (TLS enabled) |

#### Additional Ambari Ports

These ports are used by Ambari in addition to the common ports.

| Port  | Protocol | Hadoop Configuration Variable | Component |
|------:|:---------|:------------------------------|:----------|
| 1019  | TCP      | `dfs.datanode.address` | Data transfer (HDFS HA) |
| 1022  | TCP      | `dfs.datanode.http.address` | Data transfer without HTTPS (HDFS HA) |
| 8080  | TCP      |                             | Ambari Manager web interface |
| 50010 | TCP      | `dfs.datanode.address` | Data transfer |
| 50075 | TCP      | `dfs.datanode.http.address` | Data transfer without HTTPS |
