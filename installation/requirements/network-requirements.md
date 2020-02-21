# DataRobot Network Access Requirements

**NOTE**: Unless otherwise specified, "Hadoop" is applicable to both Cloudera
and Ambari clusters. Where there is something specific to Cloudera or
Ambari, it is mentioned explicitly.

In Hadoop-based installs, the **"application servers"** are any edge-node
servers, running DataRobot services _outside of Hadoop_.

**NOTE**: DataRobot is not certified to run on systems with IPv6 enabled. All `config.yaml` settings
should use IPv4, and IPv6 is disabled during `setup-dependencies`.  Re-enabling IPv6 may result in
unexpected behavior.


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
| 4369  | TCP      | HAProxy HA RabbitMQ |
| 5000  | TCP      | Docker Registry   |
| 5445  | TCP      | IDE Client Broker |
| 5446  | TCP      | IDE Client Worker |
| 5671  | TCP      | RabbitMQ TLS |
| 5671  | TCP      | HAProxy HA RabbitMQ TLS* |
| 5672  | TCP      | RabbitMQ |
| 5672  | TCP      | HAProxy HA RabbitMQ* | |
| 5673  | TCP      | HA RabbitMQ* |
| 6379  | TCP      | Redis |
| 7001  | TCP      | HAProxy Patroni Instance |
| 7558  | TCP      | Resource Monitor |
| 8000  | TCP      | DataRobot Flask Application |
| 8001  | TCP      | DataRobot v0 API |
| 8002  | TCP      | DataRobot v1 API |
| 8004  | TCP      | DataRobot v2 API |
| 8008  | TCP      | DataRobot OAuth2 API |
| 8011  | TCP      | DataRobot Socket.IO Server |
| 8018  | UDP      | Analytics Broker |
| 8023  | TCP      | DataRobot Upload Server |
| 8033  | TCP      | DataRobot Diagnostics Server |
| 8051  | TCP      | TileServer GL |
| 8097  | TCP      | DataRobot Prediction Optimization Application |
| 8100  | TCP      | DataRobot Datasets Service API |
| 9001  | TCP      | Chart Export Service |
| 9090  | TCP      | DataRobot Availability Monitor |
| 9494  | TCP      | DataRobot PNGExport Service |
| 15671 | TCP      | RabbitMQ Management HTTPS Interface |
| 15671 | TCP      | HAProxy HA RabbitMQ HTTPS Interface* |
| 15672 | TCP      | RabbitMQ Management HTTP Interface |
| 15672 | TCP      | HAProxy HA RabbitMQ Management HTTP Interface* |
| 15673 | TCP      | HA RabbitMQ Management HTTP(S) Interface* |
| 26379 | TCP      | Redis Sentinel |
| 25672 | TCP      | HA RabbitMQ inter-node communication* |
| 27017 | TCP      | MongoDB |
| 46379 | TCP      | Redis Proxy Server |

&ast; High availability configuration only

### Non-Hadoop Worker Ports

For non-Hadoop installs, additional internal ports are required for
DataRobot workers.

| Port  | Protocol | Component |
|------:|:---------|:----------|
| 5555  | TCP      | Worker Broker Client |
| 5556  | TCP      | Worker Broker |


### Gluster Ports

**NOTE**: Gluster has been deprecated as of the 5.3 release and will be completely removed
in a future release.  Please consider using MinIO instead.

If using `gluster` as a data backend, e.g. in non-Hadoop installs, additional
internal ports are required.

| Port  | Protocol | Component |
|------:|:---------|:----------|
| 111   | TCP/UDP  | Gluster Portmapper Service   |
| 24007 | TCP      | Gluster Daemon |
| 24008 | TCP      | Gluster Management |
| 24009 | TCP      | Gluster Brick |
| 49152 | TCP      | Gluster Brick |

### MinIO Ports

If using `minio` as a data backend, e.g. in non-Hadoop installs, additional
internal ports are required.

| Port  | Protocol | Component  |
|------:|:---------|:-----------|
| 9000  | TCP/UDP  | MinIO Port |

If using `minio` in an HA configuration, additional internal ports are required

| Port  | Protocol | Component     |
|------:|:---------|:--------------|
| 9002  | TCP/UDP  | MinIO HA Port |


### Optional Premium Feature Ports
These ports are only required if the referenced feature has been purchased and enabled.

| Port | Protocol | Component |
|-----:|:---------|:----------|
| 1514 | TCP      | Model Management |
| 2888 | TCP      | Model Management - Zookeeper |
| 3181 | TCP      | Model Management - Zookeeper |
| 3888 | TCP      | Model Management - Zookeeper |
| 4000 | TCP      | Model Management - HA Postgres |
| 5432 | TCP      | Model Management |
| 5433 | TCP      | Model Management - HA Postgres |
| 5434 | TCP      | Model Management - HAProxy HA Postgres |
| 9200 | TCP      | Elasticsearch for AI Catalog |
| 9300 | TCP      | Elasticsearch Internode Communication |

## Hadoop Installations

**NOTE**: Default Hadoop ports are listed here.

_Check these settings on your cluster to ensure correct firewall configuration._

### Administrator Access

These ports must be open on all Hadoop servers to allow incoming requests
from an administration server.

```
Provisioner/Administration Server => Hadoop Servers
```

#### Cloudera Manager

Administration ports necessary for Cloudera Manager.

| Port  | Protocol | Component|
|------:|:---------|:---------|
| 22    | TCP      | SSH Access to Cloudera Manager. Required only during install or upgrade |
| 7180  | TCP      | Cloudera Manager web interface |
| 7183  | TCP      | Cloudera Manager web interface (TLS enabled) |

#### Ambari Manager

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
| 22         | TCP      | | SSH port for debug purposes |
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
| 9000       | TCP      | Cloudera Manager Agent HTTP port |
| 9994-9999  | TCP      | Cloudera Monitor Services |

#### Additional Ambari Ports

Ambari agents communicate with the manager on some specific ports.
Please, make sure to open the following ports from the workers machines to the
Ambari Manager machine:

| Port       | Protocol | Component|
|-----------:|:---------|:---------|
| 8440       | TCP      | Ambari Agent Handshake port |
| 8441       | TCP      | Ambari Agent Registration and Heartbeat port |
| 8670       | TCP      | Ambari Agent ping port |

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
| 5671  | TCP      | RabbitMQ (TLS enabled on edge node) |
| 5672  | TCP      | RabbitMQ (TLS not enabled on edge node) |
| 6379  | TCP      | Redis |
| 8027  | TCP      | Hadoop Configuration Sync |
| 8100  | TCP      | DataRobot DataSets Service API |
| 15671 | TCP      | RabbitMQ HTTPS Interface (TLS enabled on edge node) |
| 15672 | TCP      | RabbitMQ HTTP Interface (TLS not enabled on edge node) |
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
| 3306  | TCP      |                               | MySQL server port, which Hive uses by default |
| 7337  | TCP      | `spark.shuffle.service.port`  | Spark Shuffle Service Port |
| 7680  | TCP      | Not configurable              | DataRobot Application Manager |
| 8020  | TCP      | `fs.default.name`, `fs.defaultFS` | NameNode IPC Port |
| 8480  | TCP      | `dfs.journalnode.http-address` | JournalNode HTTP Port. Required if using HA HDFS |
| 8481  | TCP      | `dfs.journalnode.https-address` | Secure JournalNode Web UI Port (TLS/SSL). Required if using HA HDFS and TLS |
| 8485  | TCP      | `dfs.journalnode.rpc-address` | JournalNode RPC Port. Required if using HA HDFS |
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
| 8022  | TCP      | `dfs.namenode.servicerpc-address` | NameNode Service RPC Port |
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
| 8080  | TCP      |                               | Ambari Manager web interface |
| 8141  | TCP      | `yarn.resourcemanager.admin.address` | YARN ResourceManager admin address |
| 9083  | TCP      |                               | Hive metastore port |
| 10000 | TCP      |                               | Hive server port |
| 45454 | TCP      | `yarn.nodemanager.address` | Address of the YARN NodeManager |
| 50010 | TCP      | `dfs.datanode.address` | Data transfer |
| 50075 | TCP      | `dfs.datanode.http.address` | Data transfer without HTTPS |
| 50111 | TCP      | `templeton.port` | Hive WebHCat Server port |

## All Ports In One Table

All of these are listed in one or more of the above tables.

|Port|Protocol|Component|Target Node|Source|
|---:|:-------|:--------|:----------|:-----|
|22|TCP|SSH Access|Application Servers, Cloudera Manager, Ambari Manager|Provisioner/Admin|
|22|TCP|SSH Debug|Hadoop workers|All Cluster Nodes|
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
|2888|TCP|Zookeeper Quorum Port HA Postgres|Patroni Nodes|Patroni Nodes|
|3000|TCP|DataRobot Prediction Optimization User Interface|Application Web Servers|End users|
|3003|TCP|DataRobot Tableau Extensions Service|Application Web Servers|Application Servers|
|3181|TCP|DataRobot Patroni Zookeeper client port|Patroni Nodes|Patroni Nodes|
|3306|TCP|MySQL server port, which Hive uses by default|Hortonworks workers|Hortonworks workers|
|3888|TCP|Zookeeper Election Port|Hadoop workers|Hadoop workers|
|3888|TCP|Zookeeper Election Port HA Postgres|Patroni Nodes|Patroni Nodes|
|4000|TCP|PostgreSQL in HA Mode|Patroni Nodes|Patroni Nodes|
|4369|TCP|Rabbit|Application Servers|Application Servers|
|5000|TCP|Docker Registry|Application Servers|Application Servers|
|5432|TCP|Model Management|Model Management|modmonrsyslogmaster, modmonworker and publicapi|
|5432|TCP|PostgreSQL for Hive or other services|All Hadoop Nodes|Hadoop workers|
|5433|TCP|PostgreSQL in HA Mode|Patroni Nodes|Application Servers|
|5434|TCP|HAProxy HA Postgres Master Port|Application Servers|All Cluster Nodes|
|5445|TCP|IDE Client Broker|Application Servers|Application Servers|
|5446|TCP|IDE Client Worker|Application Servers|Application Servers|
|5555|TCP|Worker Broker Client (non-Hadoop only)|Application Servers|Application Servers|
|5556|TCP|Worker Broker (non-Hadoop only)|Application Servers|Application Servers|
|5671|TCP|RabbitMQ (TLS)|RabbitMQ node|All Cluster Nodes|
|5671|TCP|HAProxy HA RabbitMQ (TLS) Port|Application Servers|All Cluster Nodes|
|5672|TCP|RabbitMQ|RabbitMQ node|All Cluster Nodes|
|5672|TCP|HAProxy HA RabbitMQ|Application Servers|All Cluster Nodes|
|5673|TCP|RabbitMQ HA (TLS/non-TLS)|RabbitMQ node|Application Servers|
|6379|TCP|Redis|Data Servers|All Cluster Nodes|
|7001|TCP|HAProxy|Application Servers|Application Servers|
|7180|TCP|Cloudera Manager web interface (CDH only) (not secure)|Cloudera Manager|Provisioner/Admin|
|7182|TCP|Cloudera Internal Communication (CDH only)|Cloudera Manager|All Cloudera Nodes|
|7183|TCP|Cloudera Manager web interface (CDH only) (TLS enabled)|Cloudera Manager|Provisioner/Admin|
|7184|TCP|Cloudera Internal Communication|Cloudera Manager|All Cloudera Nodes|
|7185|TCP|Cloudera Internal Communication|Cloudera Manager|All Cloudera Nodes|
|7186|TCP|Cloudera Internal Communication|Cloudera Manager|All Cloudera Nodes|
|7190|TCP|Cloudera P2P Parcel Distribution|All Cloudera Nodes|All Cloudera Nodes|
|7191|TCP|Cloudera P2P Parcel Distribution|All Cloudera Nodes|All Cloudera Nodes|
|7337|TCP|Spark Shuffle Service Port|Hadoop workers|Hadoop workers|
|7558|TCP|Resource Monitor|Application Servers|Application Servers|
|7680|TCP|DataRobot Application Manager|Hadoop workers|Application Servers|
|8000|TCP|DataRobot Flask Application|Application Servers|Application Servers|
|8001|TCP|DataRobot v0 API|Application Servers|Application Servers|
|8002|TCP|DataRobot v1 API|Application Servers|Application Servers|
|8004|TCP|DataRobot v2 API|Application Servers|Application Servers|
|8008|TCP|DataRobot OAuth2 API|Application Servers|Application Servers|
|8011|TCP|DataRobot Socket.IO Server|Application Servers|Application Servers|
|8018|UDP|Analytics Broker|Analytics Broker Node|All Cluster Nodes|
|8020|TCP|NameNode IPC Port|Hadoop workers|Application Servers|
|8022|TCP|NameNode Service RPC Port|Cloudera workers|Cloudera workers|
|8023|TCP|DataRobot Upload Server|Application Servers|Application Servers|
|8031|TCP|YARN Resourcemanager Resource Tracker (HDP)|Hortonworks workers|Hortonworks workers|
|8027|TCP|Hadoop Configuration Sync|Application Servers|Hadoop workers|
|8030|TCP|YARN Resourcemanager Scheduler|Hadoop workers|Hadoop workers|
|8031|TCP|YARN Resourcemanager Resource Tracker (CDH)|Hadoop workers|Hadoop workers|
|8032|TCP|YARN Resourcemanager Address(CDH)|Cloudera workers|Cloudera workers|
|8033|TCP|YARN Resourcemanager Admin (CDH)|Application Servers, Cloudera workers|Cloudera workers|
|8040|TCP|YARN NodeManager Localizer (CDH)|Cloudera workers|Cloudera workers|
|8041|TCP|YARN NodeManager Address (CDH)|Cloudera workers|Cloudera workers|
|8042|TCP|YARN NodeManager WebApp|Hadoop workers|Hadoop workers|
|8044|TCP|YARN NodeManager HTTPS (CDH)|Cloudera workers|Cloudera workers|
|8050|TCP|YARN Resourcemanager Address(HDP)|Hortonworks workers|Hortonworks workers|
|8051|TCP|TileServer GL|Application Servers|Application Servers|
|8080|TCP|Ambari Manager web interface (Ambari only)|Ambari Manager|Application Servers|
|8088|TCP|YARN ResourceManager HTTP|Hadoop workers|Application Web Servers|
|8090|TCP|YARN ResourceManager HTTPs|Hadoop workers|Application Web Servers|
|8097|TCP|DataRobot Prediction Optimization Application|Application Servers|Application Servers|
|8100|TCP|DataRobot Datasets Service API|Application Servers|All Cluster Nodes|
|8141|TCP|YARN Resourcemanager Admin (HDP)|Hortonworks workers|Hortonworks Nodes|
|8188|TCP|YARN Timeline Service webapp HTTP|Hadoop workers|Hadoop workers|
|8190|TCP|YARN Timeline Service webapp HTTPS|Hadoop workers|Hadoop workers|
|8433|TCP|Datarobot diagnostics (TLS)|Application Servers|Administrators|
|8440|TCP|Ambari Agent Handshake port|Ambari Manager|Hortonworks workers|
|8441|TCP|Ambari Agent Registration and Heartbeat port|Ambari Manager|Hortonworks workers|
|8443|TCP|Ambari Manager web interface secured (Ambari only)|Ambari Manager|Application Servers|
|8480|TCP|JournalNode HTTP Port|Hadoop workers|Hadoop workers|
|8481|TCP|Secure JournalNode Web UI Port (TLS/SSL)|Hadoop workers|Hadoop workers|
|8485|TCP|JournalNode RPC Port|Hadoop workers|Hadoop workers|
|8670|TCP|Ambari Agent ping port|Hortonworks workers|Ambari Manager|
|8833|TCP|Datarobot diagnostics (not secure)|Application Servers|Administrators|
|9000|TCP|MinIO Port|Data Servers|All Cluster Nodes|
|9000|TCP|Cloudera Manager Agent HTTP port|Cloudera workers|Cloudera Manager|
|9001|TCP|ETL Controller|Hadoop workers|Application Servers|
|9001|TCP|Chart Export Service|Application Servers|All Cluster Nodes|
|9002|TCP|MinIO HA Port|Data Servers|All Cluster Nodes|
|9083|TCP|Hive metastore port|Hortonworks workers|Hortonworks workers|
|9090|TCP|DataRobot Availability Monitor|Application Servers|Application Servers|
|9200|TCP|Elasticsearch for AI Catalog|Elasticsearch Nodes|Application Servers|
|9300|TCP|Elasticsearch Internode Communication|Elasticsearch Nodes|Elasticsearch Nodes|
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
|10000|TCP|Hive server port|Hortonworks workers|Hortonworks Nodes|
|10200|TCP|YARN Timeline Service RPC|Hadoop workers|Hadoop workers|
|14000|TCP|HTTPFS data transfer (if HTTPFS is enabled)|Hadoop workers|All Cluster Nodes|
|14001|TCP|HTTPFS administration (if HTTPFS is enabled)|Hadoop workers|All Cluster Nodes|
|15671|TCP|RabbitMQ HTTPS Interface|RabbitMQ node|Application Servers|
|15671|TCP|HAProxy HA RabbitMQ HTTPS Interface|Application Servers|Application Servers|
|15672|TCP|RabbitMQ HTTP Interface|RabbitMQ node|Application Servers|
|15672|TCP|HAProxy HA RabbitMQ HTTP Interface|Application Servers|Application Servers|
|15673|TCP|RabbitMQ HTTP(S) Interface in HA mode|RabbitMQ node|Application Servers|
|24007|TCP|Gluster Daemon|Data Servers|All Cluster Nodes|
|24008|TCP|Gluster Management|Data Servers|All Cluster Nodes|
|24009|TCP|Gluster Brick|Data Servers|All Cluster Nodes|
|25672|TCP|RabbitMQ HA inter-node communication port|RabbitMQ node|RabbitMQ node|
|26379|TCP|Redis Sentinel|Data Servers|Application Servers|
|27017|TCP|MongoDB|Data Servers|All Cluster Nodes|
|44011|TCP|DataRobot YARN Application Master Stats (DataRobot 4.2.1 and above)|Hadoop workers|Application Servers|
|44012|TCP|DataRobot YARN Application Master Stats (DataRobot 4.2.1 and above)|Hadoop workers|Application Servers|
|44013|TCP|DataRobot YARN Application Master Stats (DataRobot 4.2.1 and above)|Hadoop workers|Application Servers|
|44014|TCP|DataRobot YARN Application Master Stats (DataRobot 4.2.1 and above)|Hadoop workers|Application Servers|
|44015|TCP|DataRobot YARN Application Master Stats (DataRobot 4.2.1 and above)|Hadoop workers|Application Servers|
|44016|TCP|DataRobot YARN Application Master Stats (DataRobot 4.2.1 and above)|Hadoop workers|Application Servers|
|45454|TCP|YARN NodeManager Address (HDP)|Hortonworks workers|Hortonworks workers|
|46379|TCP|Redis Proxy Server|Application Servers|Application Servers|
|49152|TCP|Gluster Brick|Data Servers|All Cluster Nodes|
|50010|TCP|Data transfer (Ambari only)|Hortonworks workers|Application Servers|
|50020|TCP|HDFS Metadata operations|Hadoop workers|Application Servers|
|50070|TCP|NameNode Web UI without HTTPS|Hadoop workers|Application Servers|
|50075|TCP|Data transfer without HTTPS (Ambari only)|Hortonworks workers|Application Servers|
|50090|TCP|Secondary NameNode without HTTPS|Hadoop workers|Application Servers|
|50091|TCP|Secondary NameNode with HTTPS|Hadoop workers|Application Servers|
|50111|TCP|Hive WebHCat Server port|Hortonworks workers|Hortonworks Nodes|
|50470|TCP|NameNode Web UI with HTTPS|Hadoop workers|Application Servers|
|50475|TCP|Data Transfer with HTTPS|Hadoop workers|Application Servers|
