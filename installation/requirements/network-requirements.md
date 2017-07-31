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

The following ports must be opened between all Linux nodes in the application server cluster.

| Port  | Protocol | Component |
|------:|:---------|:----------|
| 80    | TCP      | NGINX     |
| 443   | TCP      | NGINX     |
| 1514  | UDP      | Logging   |
| 5000  | TCP      | Docker Registry   |
| 5445  | TCP      | IDE Client Broker |
| 5446  | TCP      | IDE Client Worker |
| 5544  | UDP      | Audit Logs |
| 5555  | TCP      | Worker Broker Client |
| 5556  | TCP      | Worker Broker |
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
| 8100  | TCP      | DataRobot Datasets Service API |
| 9000  | TCP      | DataRobot Prediction Optimization Application |
| 9090  | TCP      | DataRobot Availability Monitor |
| 9496  | TCP      | DataRobot PNGExport Service |
| 24007-24009 | TCP | Gluster |
| 26379 | TCP      | Redis Sentinel
| 27017 | TCP      | Mongo |

## Cloudera Installations

### Administrator Access for Cloudera Manager
| Port  | Protocol | Component|
|------:|:---------|:---------|
| 22    | TCP      | SSH Access |
| 7180  | TCP      | Cloudera Manager web interface |
| 7183  | TCP      | Cloudera Manager web interface (SSL enabled) |

### Communication from the Cloudera Cluster to the application servers
| Port  | Protocol | Component|
|------:|:---------|:---------|
| 80    | TCP      | HTTP traffic for config sync (SSL not enabled on edge node) |
| 443   | TCP      | HTTPS traffic for config sync (SSL enabled on edge node) |
| 8100  | TCP      | DSS API |
| 6556  | TCP      | Reverse Proxy |
| 6558  | TCP      | Reverse Proxy |
| 1514  | UDP      | Logging |
| 27017 | TCP      | Mongo |
| 6379  | TCP      | Redis |

### Communication from application servers to the Cloudera Cluster
**NOTE**: Default Cloudera ports are listed here.
Check these settings on your cluster to ensure correct firewall configuration.

| Port  | Protocol | Hadoop Configuration Variable | Component |
|------:|:---------|:------------------------------|:----------|
| 7180  | TCP      | HTTP Port for Admin Console   | Cloudera Manager |
| 2181  | TCP      | `clientPort`                  | ZooKeeper client port |
| 7680  | TCP      | Not configurable              | DR Application Manager |
| 50070 | TCP      | `dfs.namenode.http-address`   | NameNode Web UI without HTTPS |
| 1006  | TCP      | `dfs.datanode.http.address`   | Data transfer without HTTPS |
| 50470 | TCP      | `dfs.namenode.https-address`  | NameNode Web UI with HTTPS |
| 50475 | TCP      | `dfs.datanode.https.address`  | Data Transfer with HTTPS |
| 50090 | TCP      | `dfs.namenode.secondary.http-address` | Secondary NameNode without HTTPS |
| 50091 | TCP      | `dfs.namenode.secondary.https-address` |  Secondary NameNode with HTTPS |
