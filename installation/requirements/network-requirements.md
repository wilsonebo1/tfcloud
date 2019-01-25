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
| 8433  | TCP      | Datarobot diagnostics (TLS) |
| 8833  | TCP      | Datarobot diagnostics (not secure) |

## Internal Ports

The following ports must be opened between all Linux nodes in the
application server cluster, whether or not using Hadoop.

| Port  | Protocol | Component |
|------:|:---------|:----------|
| 80    | TCP      | NGINX     |
| 443   | TCP      | NGINX     |
| 1514  | UDP      | Application Web   |
| 3000  | TCP      | DataRobot Prediction Optimization User Interface |
| 3003  | TCP      | DataRobot Tableau Extensions Service |
| 5000  | TCP      | Docker Registry   |
| 5445  | TCP      | IDE Client Broker |
| 5446  | TCP      | IDE Client Worker |
| 5672  | TCP      | RabbitMQ |
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
| 8018  | UDP      | Analytics Broker |
| 8023  | TCP      | DataRobot Upload Server |
| 8033  | TCP      | DataRobot Diagnostics Server |
| 8097  | TCP      | DataRobot Prediction Optimization Application |
| 8100  | TCP      | DataRobot Datasets Service API |
| 9090  | TCP      | DataRobot Availability Monitor |
| 9494  | TCP      | DataRobot PNGExport Service |
| 15672 | TCP      | RabbitMQ HTTP Interface |
| 26379 | TCP      | Redis Sentinel |
| 27017 | TCP      | MongoDB |

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

### Optional Premium Feature Ports
These ports are only required if the referenced feature has been purchased and enabled.

| Port  | Protocol | Component |
|------:|:---------|:----------|
| 5432  | TCP      | Model Management |
| 1514  | TCP      | Model Management |

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
| 22    | TCP      | SSH Access to Cloudera Manager. Required only during install or upgrade |
| 7180  | TCP      | Cloudera Manager web interface |
| 7183  | TCP      | Cloudera Manager web interface (TLS enabled) |

#### Ambari

Administration ports necessary for Ambari Manager.

| Port  | Protocol | Component|
|------:|:---------|:---------|
| 22    | TCP      | SSH Access to Ambari server. Required only during install or upgrade |
| 8080  | TCP      | Ambari Manager web interface |
| 8443  | TCP      | Ambari Manager web interface (TLS enabled) |


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

| Port       | Protocol | Hadoop Configuration Variable | Component|
|-----------:|:---------|:------------------------------|:---------|
| 2888       | TCP      | | Zookeeper Quorum Port |
| 3888       | TCP      | | Zookeeper Election Port |
| 8030       | TCP      | `yarn.resourcemanager.scheduler.address` | YARN Scheduler Port |
| 8031       | TCP      | `yarn.resourcemanager.resource-tracker.address` | YARN Resource Tracker Port |
| 8042       | TCP      | `yarn.nodemanager.webapp.address` | YARN NodeManager Webapp Address |
| 8044       | TCP      | `yarn.nodemanager.webapp.https.address` | YARN NodeManager HTTPS |
| 8088       | TCP      | `yarn.resourcemanager.webapp.address` | YARN ResourceManager HTTP |
| 8090       | TCP      | `yarn.resourcemanager.webapp.https.address` | YARN ResourceManager HTTPS |
| 8188       | TCP      | `yarn.timeline-service.webapp.address` | YARN Timeline Server HTTP |
| 8190       | TCP      | `yarn.timeline-service.webapp.https.address` | YARN Timeline Server HTTPS |
| 10200      | TCP      | `yarn.timeline-service.address` | YARN Timeline Server RPC |
| 14000      | TCP      | `hdfs.httpfs.http.port` | HTTPFS data transfer (if HTTPFS is enabled)|
| 14001      | TCP      | `hdfs.httpfs.admin.port` | HTTPFS administration (if HTTPFS is enabled)|
| 5432       | TCP      | | PostgreSQL port in case of using Hive with PorstgreSQL or other services, which require DB|

#### Additional Cloudera Ports

Cloudera installs require additional ports of communication within
the Hadoop cluster. Some of these ports may be different
depending on configuration in your Cloudera Manager.

Example ports include:

| Port       | Protocol | Component|
|-----------:|:---------|:---------|
| 7182-7186  | TCP      | Cloudera Internal Communication |
| 7190-7191  | TCP      | Cloudera P2P Parcel Distribution |
| 9994-9999  | TCP      | Cloudera Monitor Services |

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
| 1514  | UDP      | Application Web |
| 5672  | TCP      | RabbitMQ |
| 6379  | TCP      | Redis |
| 6556  | TCP      | Resource Proxy Subscriber |
| 6558  | TCP      | Queue Proxy Subscriber |
| 8027  | TCP      | Hadoop Configuration Sync |
| 8100  | TCP      | DataRobot DataSets Service API |
| 15672 | TCP      | RabbitMQ HTTP Interface |
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
| 8485  | TCP      | `dfs.journalnode.rpc-address` | Required if using HA HDFS |
| 9001  | TCP      | Not configurable              | ETL Controller |
| 50020 | TCP      | `dfs.datanode.ipc.address` | HDFS Metadata operations |
| 50070 | TCP      | `dfs.namenode.http-address` | NameNode Web UI without HTTPS |
| 50090 | TCP      | `dfs.namenode.secondary.http-address` | Secondary NameNode without HTTPS |
| 50091 | TCP      | `dfs.namenode.secondary.https-address` | Secondary NameNode with HTTPS |
| 50470 | TCP      | `dfs.namenode.https-address`  | NameNode Web UI with HTTPS |
| 50475 | TCP      | `dfs.datanode.https.address`  | Data Transfer with HTTPS |
| 14000 | TCP      | Not configurable              | HTTPFS data transfer (if HTTPFS is enabled)|
| 14001 | TCP      | Not configurable              | HTTPFS administration (if HTTPFS is enabled)|


These ports are only used on DataRobot 4.2.1 and above.

| Port  | Protocol | Hadoop Configuration Variable | Component |
|------:|:---------|:------------------------------|:----------|
| 44011-44016 | TCP      | Not configurable              | DataRobot YARN Application Master Stats |

#### Additional Cloudera Ports

These ports are used by Cloudera in addition to the common ports.
Following ports are for CDH5.x. Please, see section below for changes in CDH6.x.

| Port  | Protocol | Hadoop Configuration Variable | Component |
|------:|:---------|:------------------------------|:----------|
| 1004  | TCP      | `dfs.datanode.address` | Data transfer (HDFS HA) |
| 1006  | TCP      | `dfs.datanode.http.address`| Data transfer without HTTPS (HDFS HA) |
| 7180  | TCP      |                               | Cloudera Manager web interface |
| 7183  | TCP      |                               | Cloudera Manager web interface (TLS enabled) |
| 8032  | TCP      | `yarn.resourcemanager.address` | For application submissions |
| 8033  | TCP      | `yarn.resourcemanager.admin.address` | YARN ResourceManager admin address |
| 8040  | TCP      | `yarn.nodemanager.localizer.address` | YARN NodeManager localizer address |
| 8041  | TCP      | `yarn.nodemanager.address` | Address of the YARN NodeManager |

#### Changes in CDH 6.x

There are multiple services, default ports of which were changed in CDH 6.x.
Please, use these ports if you're using CDH6.x.

| CDH6.x port | CDH5.x port | Protocol | Hadoop Configuration Variable | Component |
|------------:|------------:|:---------|:------------------------------|:----------|
| 9866        | 1004        | TCP      | `dfs.datanode.address` | Data transfer (HDFS HA) |
| 9864        | 1006        | TCP      | `dfs.datanode.http.address`| Data transfer without HTTPS (HDFS HA) |
| 9867        | 50020       | TCP      | `dfs.datanode.ipc.address` | HDFS Metadata operations |
| 9870        | 50070       | TCP      | `dfs.namenode.http-address` | NameNode Web UI without HTTPS |
| 9871        | 50470       | TCP      | `dfs.namenode.https-address`  | NameNode Web UI with HTTPS |
| 9865        | 50475       | TCP      | `dfs.datanode.https.address`  | Data Transfer with HTTPS |

#### Additional Ambari Ports

These ports are used by Ambari in addition to the common ports.

| Port  | Protocol | Hadoop Configuration Variable | Component |
|------:|:---------|:------------------------------|:----------|
| 1019  | TCP      | `dfs.datanode.address` | Data transfer (HDFS HA) |
| 1022  | TCP      | `dfs.datanode.http.address` | Data transfer without HTTPS (HDFS HA) |
| 8050  | TCP      | `yarn.resourcemanager.address` | For application submissions |
| 8080  | TCP      |                             | Ambari Manager web interface |
| 8141  | TCP      | `yarn.resourcemanager.admin.address` | YARN ResourceManager admin address |
| 45454 | TCP      | `yarn.nodemanager.address` | Address of the YARN NodeManager |
| 50010 | TCP      | `dfs.datanode.address` | Data transfer |
| 50075 | TCP      | `dfs.datanode.http.address` | Data transfer without HTTPS |

## All Ports In One Table

All of these are listed in one or more of the above tables.

|Port|Protocol|Component|Target Node|Source|
|---:|:-------|:--------|:----------|:-----|
|22|TCP|SSH Access|Application Servers, Cloudera Manager, Ambari Manager|Provisioner/Admin|
|80|TCP|HTTP (not secure)|Application Web Servers|End users, All Cluster Nodes|
|111|TCP/UDP|Gluster Portmapper Service (non-Hadoop only)|Data Servers|All Cluster Nodes|
|443|TCP|HTTPS (TLS)|Application Web Servers|End users, All Cluster Nodes|
|1004|TCP|Data transfer (HDFS HA) (Cloudera only)|Cloudera workers|Application Servers|
|1006|TCP|Data transfer without HTTPS (HDFS HA) (Cloudera only)|Cloudera workers|Application Servers|
|1019|TCP|Data transfer (HDFS HA) (Ambari only)|Hortonworks workers|Application Servers|
|1022|TCP|Data transfer without HTTPS (HDFS HA) (Ambari only)|Hortonworks workers|Application Servers|
|1514|UDP|Application Web|Provisioner/Admin|All Cluster Nodes|
|1514|TCP|Logging|Model Management|Dedicated Prediction Workers|
|2181|TCP|ZooKeeper client port|Hadoop workers|Application Servers|
|2888|TCP|Zookeeper Quorum Port|Hadoop workers|Hadoop workers|
|3000|TCP|DataRobot Prediction Optimization User Interface|Application Web Servers|End users|
|3003|TCP|DataRobot Tableau Extensions Service|Application Web Servers|Application Servers|
|3888|TCP|Zookeeper Election Port|Hadoop workers|Hadoop workers|
|5000|TCP|Docker Registry|Application Servers|Application Servers|
|5432|TCP|Model Management|Model Management|modmonrsyslogmaster, modmonworker and publicapi|
|5432|TCP|PostgreSQL for Hive or other services|All Hadoop Nodes|Hadoop workers|
|5445|TCP|IDE Client Broker|Application Servers|Application Servers|
|5446|TCP|IDE Client Worker|Application Servers|Application Servers|
|5672|TCP|RabbitMQ|RabbitMQ node|All Cluster Nodes|
|6379|TCP|Redis|Data Servers|All Cluster Nodes|
|6556|TCP|Resource Proxy Subscriber|Application Servers|All Cluster Nodes|
|6557|TCP|Resource Proxy Publisher|Application Servers|Application Servers|
|6558|TCP|Queue Proxy Subscriber|Application Servers|All Cluster Nodes|
|6559|TCP|Queue Proxy Publisher|Application Servers|Application Servers|
|7180|TCP|Cloudera Manager web interface (CDH only) (not secure)|Cloudera Manager|Provisioner/Admin|
|7182|TCP|Cloudera Internal Communication (CDH only)|Cloudera Manager|All Cloudera Nodes|
|7183|TCP|Cloudera Manager web interface (CDH only) (TLS enabled)|Cloudera Manager|Provisioner/Admin|
|7184|TCP|Cloudera Internal Communication|Cloudera Manager|All Cloudera Nodes|
|7185|TCP|Cloudera Internal Communication|Cloudera Manager|All Cloudera Nodes|
|7186|TCP|Cloudera Internal Communication|Cloudera Manager|All Cloudera Nodes|
|7190|TCP|Cloudera P2P Parcel Distribution|All Cloudera Nodes|All Cloudera Nodes|
|7191|TCP|Cloudera P2P Parcel Distribution|All Cloudera Nodes|All Cloudera Nodes|
|7680|TCP|DataRobot Application Manager|Hadoop workers|Application Servers|
|8000|TCP|DataRobot Flask Application|Application Servers|Application Servers|
|8001|TCP|DataRobot v0 API|Application Servers|Application Servers|
|8002|TCP|DataRobot v1 API|Application Servers|Application Servers|
|8004|TCP|DataRobot v2 API|Application Servers|Application Servers|
|8011|TCP|DataRobot Socket.IO Server|Application Servers|Application Servers|
|8018|UDP|Analytics Broker|Analytics Broker Node|All Cluster Nodes|
|8020|TCP|NameNode IPC Port|Hadoop workers|Application Servers|
|8023|TCP|DataRobot Upload Server|Application Servers|Application Servers|
|8031|TCP|YARN Resourcemanager Resource Tracker (HDP)|Hortonworks workers|Hortonworks workers|
|8027|TCP|Hadoop Configuration Sync|Application Servers|Hadoop workers|
|8030|TCP|YARN Resourcemanager Scheduler|Hadoop workers|Hadoop workers|
|8031|TCP|YARN Resourcemanager Resource Tracker (CDH)|Hadoop workers|Hadoop workers|
|8032|TCP|YARN Resourcemanager Address(CDH)|Cloudera workers|Cloudera workers|
|8033|TCP|YARN Resourcemanager Admin (CDH)|Cloudera workers|Cloudera workers|
|8040|TCP|YARN NodeManager Localizer (CDH)|Cloudera workers|Cloudera workers|
|8041|TCP|YARN NodeManager Address (CDH)|Cloudera workers|Cloudera workers|
|8042|TCP|YARN NodeManager WebApp|Hadoop workers|Hadoop workers|
|8044|TCP|YARN NodeManager HTTPS (CDH)|Cloudera workers|Cloudera workers|
|8050|TCP|YARN Resourcemanager Address(HDP)|Hortonworks workers|Hortonworks workers|
|8080|TCP|Ambari Manager web interface (Ambari only)|Ambari Manager|Application Servers|
|8088|TCP|YARN ResourceManager HTTP|Hadoop workers|Application Web Servers|
|8090|TCP|YARN ResourceManager HTTPs|Hadoop workers|Application Web Servers|
|8097|TCP|DataRobot Prediction Optimization Application|Application Servers|Application Servers|
|8100|TCP|DataRobot Datasets Service API|Application Servers|Application Servers|
|8141|TCP|YARN Resourcemanager Admin (HDP)|Hortonworks workers|Hortonworks Nodes|
|8188|TCP|YARN Timeline Service webapp HTTP|Hadoop workers|Hadoop workers|
|8190|TCP|YARN Timeline Service webapp HTTPS|Hadoop workers|Hadoop workers|
|8433|TCP|Datarobot diagnostics (TLS)|Application Servers|Administrators|
|8443|TCP|Ambari Manager web interface secured (Ambari only)|Ambari Manager|Application Servers|
|8485|TCP|Required if using HA HDFS|Hadoop workers|Application Servers|
|8833|TCP|Datarobot diagnostics (not secure)|Application Servers|Administrators|
|9001|TCP|ETL Controller|Hadoop workers|Application Servers|
|9090|TCP|DataRobot Availability Monitor|Application Servers|Application Servers|
|9494|TCP|DataRobot PNGExport Service|Application Servers|Application Servers|
|9866|TCP|Data transfer (HDFS HA) (CDH 6.x)|Cloudera workers|Application Servers|
|9864|TCP|Data transfer without HTTPS (HDFS HA) (CDH 6.x)|Cloudera workers|Application Servers|
|9867|TCP|HDFS Metadata operations (CDH 6.x)|Cloudera workers|Application Servers|
|9870|TCP|NameNode Web UI without HTTPS (CDH 6.x)|Cloudera workers|Application Servers|
|9871|TCP|NameNode Web UI with HTTPS (CDH 6.x)|Cloudera workers|Application Servers|
|9865|TCP|Data Transfer with HTTPS (CDH 6.x)|Cloudera workers|Application Servers|
|9994|TCP|Cloudera Host Monitor's query API|Cloudera Manager|Cloudera workers|
|9995|TCP|Cloudera Host Monitor, listening for agent messages|Cloudera Manager|Cloudera workers|
|9996|TCP|Cloudera Service Monitor's query API|Cloudera Manager|Cloudera workers|
|9997|TCP|Cloudera Service Monitor, listening for agent messages|Cloudera Manager|Cloudera workers|
|9998|TCP|Cloudera Activity Monitor's query API|Cloudera Manager|Cloudera workers|
|9999|TCP|Cloudera Activity Monitor, listening for agent messages|Cloudera Manager|Cloudera workers|
|10200|TCP|YARN Timeline Service RPC|Hadoop workers|Hadoop workers|
|14000|TCP|HTTPFS data transfer (if HTTPFS is enabled)|Hadoop workers|All Cluster Nodes|
|14001|TCP|HTTPFS administration (if HTTPFS is enabled)|Hadoop workers|All Cluster Nodes|
|15672|TCP|RabbitMQ HTTP Interface|RabbitMQ node|Application Servers|
|24007|TCP|Gluster Daemon|Data Servers|All Cluster Nodes|
|24008|TCP|Gluster Management|Data Servers|All Cluster Nodes|
|24009|TCP|Gluster Brick|Data Servers|All Cluster Nodes|
|26379|TCP|Redis Sentinel|Data Servers|Application Servers|
|27017|TCP|MongoDB|Data Servers|All Cluster Nodes|
|44011|TCP|DataRobot YARN Application Master Stats (DataRobot 4.2.1 and above)|Hadoop workers|Application Servers|
|44012|TCP|DataRobot YARN Application Master Stats (DataRobot 4.2.1 and above)|Hadoop workers|Application Servers|
|44013|TCP|DataRobot YARN Application Master Stats (DataRobot 4.2.1 and above)|Hadoop workers|Application Servers|
|44014|TCP|DataRobot YARN Application Master Stats (DataRobot 4.2.1 and above)|Hadoop workers|Application Servers|
|44015|TCP|DataRobot YARN Application Master Stats (DataRobot 4.2.1 and above)|Hadoop workers|Application Servers|
|44016|TCP|DataRobot YARN Application Master Stats (DataRobot 4.2.1 and above)|Hadoop workers|Application Servers|
|45454|TCP|YARN NodeManager Address (HDP)|Hortonworks workers|Hortonworks workers|
|49152|TCP|Gluster Brick|Data Servers|All Cluster Nodes|
|50010|TCP|Data transfer (Ambari only)|Hortonworks workers|Application Servers|
|50020|TCP|HDFS Metadata operations|Hadoop workers|Application Servers|
|50070|TCP|NameNode Web UI without HTTPS|Hadoop workers|Application Servers|
|50075|TCP|Data transfer without HTTPS (Ambari only)|Hortonworks workers|Application Servers|
|50090|TCP|Secondary NameNode without HTTPS|Hadoop workers|Application Servers|
|50091|TCP|Secondary NameNode with HTTPS|Hadoop workers|Application Servers|
|50470|TCP|NameNode Web UI with HTTPS|Hadoop workers|Application Servers|
|50475|TCP|Data Transfer with HTTPS|Hadoop workers|Application Servers|
