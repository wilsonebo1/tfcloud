# Kubernetes cluster tests

K8s-installer (aka `kuberobot`) is shipped with 2 different set of tests:
- pre-flight-checks
- standard-datarobot-k8s-cluster

## Pre-flight checks
These tests are specifically designed to verify that kubernetes cluster built outside of DataRobot will work with kuberobot extensions (i.e. `datascience_platform`, `dataengine`, etc.)
In other words check if the given cluster can be used for `byoc` plugin.

### What is checked?
- k8s objects in kube-system namespace can be created
- cluster wide custom resource definitions can be created
- cluster has required custom resource definitions
- required custom objects exist
- LoadBalancer's hostname can be reached via HTTP request from outside world
- persistent volume claim shared between two pods

### How to run?
To run k8s pre-flight checks please proceed with following steps as the unprivileged user (usually defined as user in `config.yaml`):
1. Copy `kubeconfig` file to the web-server node 
```bash
scp <path_to_kubeconfig> <unpriviledged-user>@<web-server-address>:/opt/datarobot/DataRobot-x.x.x
```
2. SSH onto web-server node and add the following settings in `config.yaml` in order to enable running kubernetes commands
```
kubernetes:
  clusters:
  - name: <cluster_name_from_kubeconfig>
```
3. That's it. We are ready to run pre-flight checks.
_NOTE:_ command needs to be run from `/opt/datarobot/DataRobot-x.x.x/` directory:
```bash
bin/datarobot kubernetes pre-flight-check
```

## Standard DataRobot K8s Cluster
These tests are verifying that the cluster created by _kuberobot_ is ready to work with kubernetes specific DataRobot features.

### What is checked?
- cluster connection
- role-based access control
- persistent storage usage
- monitoring and logging features
- metrics exposure for prometheus adapter
- DNS-1123 naming conversion is enforced

### How to run?
Tests can be triggered using following command from `/opt/datarobot/DataRobot-x.x.x/` directory:
```bash
bin/datarobot kubernetes test
```
_NOTE:_ This suite is designed to confirm functionality of clusters created by _kuberobot_ and might fail for all others.
