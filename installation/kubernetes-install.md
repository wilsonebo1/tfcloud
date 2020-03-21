# Kubernetes Installation Instructions

Starting in DataRobot 5.3 DataRobot can install kubernetes cluster on AWS or GCP and run 
Custom Models on it.

Install order:

1. DR dependencies
2. Run-registry
2. Kubernetes
3. [LRS operator](./special-topics/lrs-operator-configuration.md#automatic-lrs-operator-installation-using-datarobot-installer)
4. Datarobot  

## AWS  

### Access Requirements

The administrator must be in the `Administrators` IAM group to be able to manage IAM roles and 
policies, create Route53 domain zones etc. 

### Account Requirements

Before starting the installation and integration account should be prepared 
by the administrators of the account and you should have the following list 
of values/files from them:

* VPC ID (`vpc-id`)
* IDs for 3 private VPC subnets (`subnet-1` `subnet-2` `subnet-3`) - could be any internal subnets
* IDs for 3 public VPC subnets (`pub-subnet-1` `pub-subnet-2` `pub-subnet-3`) - [VPC with Public and Private Subnets (NAT)](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
* Cluster name (`<cluster-name>`)
* AWS region (`aws-region`)
* SSH Key file (`<cluster-name>.pem`) 
* [Key Pair name](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) (`<cluster-name>`)
* Private DNS Zone name (`private-domain-zone`)
* Public DNS Zone name (`public-domain-zone`)
* IAM roles:
  * `<cluster_name>-k8s-etcd`
  * `<cluster_name>-k8s-master`
  * `<cluster_name>-k8s-worker`
  * `<cluster_name>-k8s-base` (arn)
  * `<cluster_name>-k8s-autoscaler` (arn)
  * `<cluster_name>-k8s-cert-manager` (arn)
  * `<cluster_name>-k8s-ec2-srcdst` (arn)
  * `<cluster_name>-k8s-external-dns` (arn)
* Email for the Let's Encrypt (LE). (`<email>`) it could be any existing email. Will be used 
by Let's Encrypt service to send notifications. It's better to use some of our email to get notified 
in case of any issues with the client Let's Encrypt.  
* Registry password. (`<registry_password>`) Password to be used for custom models registry inside a 
Kubernetes installation. We recommend to use password generator to choose one. 
* Registry username. (`<registry_username>`) User to be used for custom models registry inside a 
 Kubernetes installation. We recommend to use `<cluste_name>` as one.

Account preparation described in the separate document.  

### Copy required files

Copy `<cluster-name>.pem` to the `/kubernetes` under installation folder 
(`/opt/datarobot/DataRobot-6.x.x/kubernetes/<cluster-name>.pem`, for example). Change permissions 
to the file to `600`.

### Preparing DataRobot `config.yaml`

Update `config.yaml` to looks like below. 
This will configure kubernetes cluster creation and enable it’s support in the DataRobot:

```yaml
...
app_configuration:
  ...
  drenv_override:
    ...
    LONG_RUNNING_SERVICES_INGRESS_SSL_REDIRECT: true
    LONG_RUNNING_SERVICES_USE_OPERATOR: true
    LONG_RUNNING_SERVICES_OPERATOR_INSTANCE_NAME: dsp-lrs-operator
    CUSTOM_MODELS_FQDN: custom-model-<cluster-name>-dsp.<public-domain-zone>
    ENABLE_PIPELINE: true
    EXECUTION_ENVIRONMENTS_DOCKER_IMAGE_NAME: <registry_username>:<registry_password>@repo-<cluster-name>-dsp.<public-domain-zone>/datarobot/ee
    KUBECONFIG_PATH: /opt/datarobot-runtime/etc/kubeconfig/kubeconfig

kubernetes:
  clusters:
  - lrs-operator:
      docker-image: repo-<cluster-name>-dsp.<public-domain-zone>/datarobot/operator-lrs
      docker-registry-password: topsecret
      docker-registry-username: docker
      ingress-annotation-prefix: nginx.dsp.ingress.kubernetes.io
      ingress-class: nginx-dsp
      ingress-tls-enable: true
      instance-name: dsp-lrs-operator
    name: <cluster-name>-dsp
    settings:
      aws:
        aws_region: <aws-region>        
        autoscaler_role: arn for <cluster-name>-k8s-autoscaler
        base_role: arn for <cluster-name>-k8s-base
        cert_manager_role: arn for <cluster-name>-k8s-cert-manager
        ec2_srcdst_role: arn for <cluster-name>-k8s-ec2-srcdst
        external_dns_role: arn for <cluster-name>-k8s-external-dns
        etcd_profile: <cluster-name>-k8s-etcd
        master_profile: <cluster-name>-k8s-master
        worker_profile: <cluster-name>-k8s-worker
        grafana_password: DataRobot
        grafana_username: DataRobot
        kibana_password: DataRobot
        kibana_username: DataRobot
        letsencrypt-environment: prod
        letsencrypt-user-email: <email>
        private-domain-zone: <private-dns-zone-name>
        public-domain-zone: <public-dns-zone-name>
        ssh_key_path: <cluster-name>.pem
        ssh_key_name: <cluster-name>
        subnets: <subnet-id-1> <subnet-id-2> <subnet-id-3>
        public_subnets: <pub-subnet-id-1> <pub-subnet-id-2> <pub-subnet-id-3>
        vpc_id: <vpc-id>
      datascience_platform:
        domain_zone: <public-dns-zone-name>
        registry_hostname: repo-<cluster-name>-dsp
        registry_password: <registry_password>
        registry_storage_bytes: 53687091200
        registry_username: <registry_username>
      extension: datascience_platform
      plugin: aws
  enable: true
  ...
``` 

### Install Kubernetes

```
./bin/datarobot kubernetes create
```

### Install Operator for the Custom Models

```
$ ./bin/datarobot lrs_operator install
```

### Delete Kubernetes

```
$ ./bin/datarobot kubernetes delete
```

## GCP

Before starting the installation and integration account should be prepared by the administrators of 
the account and you should have the following list of values/files from them:
ServiceAccount credentials key file saved as `<*.JSON>` with AdministratorAccess rights.

### Required values

* VPC
* VPC subnet
* Cluster name
* GCP region
* SSH Key file pub part (`<cluster-name>.pub`)
* SSH Key file private part (`<cluster-name>.pem`)
* Public DNS Zone name
* Copy required files
* Copy `<*>` (private ssh key) to the `/opt/tmp/kubernetes`
* Copy `<*>.pub` to the `/opt/tmp/kubernetes`
* Copy `<*>.JSON` to the `/opt/tmp/kubernetes`
* Email for the Let's Encrypt (LE). (`<email>`) it could be any existing email. Will be used 
by Let's Encrypt service to send notifications. It's better to use some of our email to get notified 
in case of any issues with the client Let's Encrypt.  
* Registry password. (`<registry_password>`) Password to be used for custom models registry inside a 
Kubernetes installation. We recommend to use password generator to choose one. 
* Registry username. (`<registry_username>`) User to be used for custom models registry inside a 
 Kubernetes installation. We recommend to use `<cluste_name>` as one.

### Preparing DataRobot `config.yaml`

Update `config.yaml` to looks like below. 
This will configure kubernetes cluster creation and enable its support in the DataRobot:

```yaml
...
app_configuration:
  ...
  drenv_override:
    ...
    LONG_RUNNING_SERVICES_INGRESS_SSL_REDIRECT: true
    LONG_RUNNING_SERVICES_USE_OPERATOR: true
    LONG_RUNNING_SERVICES_OPERATOR_INSTANCE_NAME: dsp-lrs-operator
    CUSTOM_MODELS_FQDN: custom-model-<cluster-name>-dsp.<public-domain-zone>.<parent-domain-zone>
    ENABLE_PIPELINE: true
    EXECUTION_ENVIRONMENTS_DOCKER_IMAGE_NAME: <registry_username>:<registry_password>@repo-<cluster-name>-dsp.<public-domain-zone>.<parent-domain-zone>/datarobot/ee
    KUBECONFIG_PATH: /opt/datarobot-runtime/etc/kubeconfig/kubeconfig
...
kubernetes:
  clusters:
  - lrs-operator:
      docker-image: repo-<cluster-name>-dsp.<public-domain-zone>.<parent-domain-zone>/datarobot/operator-lrs
      docker-registry-password: topsecret
      docker-registry-username: docker
      ingress-annotation-prefix: nginx.dsp.ingress.kubernetes.io
      ingress-class: nginx-dsp
      ingress-tls-enable: true
      instance-name: dsp-lrs-operator
    name: <cluster-name>-dsp
    settings:
      gcp:
        ssh_pub_key_path: <cluster-name>.pub
        ssh_private_key_path: <cluster-name>.pem
        vpc_name: <vpc-name>
        vpc_subnet_name: <vpc-subnet-name>
        region_name: <gcp-region>
        project_id: <gcp-project-name>
        credentials_file_path: <gcp-service-account-credentials-json-file>
        certmanager-service-account-key-file-path: <gcp-service-account-credentials-json-file>
        certmanager_service_account_key_file_path: <gcp-service-account-credentials-json-file>
        external_dns_service_account_key_file_path: <gcp-service-account-credentials-json-file>
        cluster_autoscaler_service_account_key_file_path: <gcp-service-account-credentials-json-file>
        public_domain_zone: <public-domain-zone>
        parent_domain_zone: <parent-domain-zone>
        grafana_username: DataRobot
        grafana_password: DataRobot
        kibana_username: DataRobot
        kibana_password: DataRobot
        letsencrypt-environment: prod
        letsencrypt-user-email: <email>
      datascience_platform:
        domain_zone: <public-domain-zone>.<parent-domain-zone>
        registry_hostname: repo-<cluster-name>-dsp
        registry_password: <registry_password>
        registry_storage_bytes: 53687091200
        registry_username: <registry_username>
      extension: datascience_platform
      plugin: gcp
  enable: true
 ...
```

Make sure `./kubernetes` folder contains all necessary files, such as `<cluster-name>.pem`, `<cluster-name>.pub` and `<gcp-service-account-credentials-file>.JSON` (service account credentials key)

### Description `config.yaml` parameters 

Lrs-operator section:
* `docker-image`: `repo-{{ CLUSTER_NAME }}-{{ PUBLIC_DOMAIN_ZONE }}-{{ PARENT_DOMAIN_ZONE }}/…`

Plugin settings:
* `ssh_pub_key_path`: must present in `./kubernetes` directory
* `ssh_private_key_path`: must present in `./kubernetes` directory
* `credentials_file_path`: must present in `./kubernetes` directory
* `certmanager-service-account-key-file-path`, `external_dns_service_account_key_file_path`, 
`cluster_autoscaler_service_account_key_file_path`: must present in `./kubernetes` directory 
and can use the same  `<credentials_file_path>` file
* `public_domain_zone`: available public DNS zone from you cloud provider
* `parent_domain_zone`: the name of domain you own
* `grafana_username`: The string parameter for creating username for Grafana UI
* `grafana_password`: The string parameter for creating password for Grafana UI
* `kibana_username`: The string parameter will be used for creating username for Kibana UI
* `kibana_password`: The string parameter will be used for creating password for Kibana UI
* `letsencrypt-environment`: The string parameter, should be `prod` for any production environments
* `letsencrypt-user-email`: The email which will be used for Let's Encrypt notifications, put `<your-email>`

Extension settings:
* `domain_zone`: `<public-domain-zone>.<parent-domain-zone>`
* `registry_hostname`: `repo-<cluster-name>`
* `registry_password`: 
* `registry_storage_bytes`: `53687091200` - this is the value of registry disk size we want to use 
* `registry_username`: the string parameter will be used for specifing extension docker registry username
* `extension`: `<extension-name>`
* `plugin`: `<plugin-name>`

### Install Kubernetes

```
$ ./bin/datarobot kubernetes create
```

In a case of reusing `config.yaml`, DataRobot application can be and should be reconfigured 
according to new values from the `config.yaml`:
```
$ ./bin/datarobot reconfigure
```

### Install Operator for the Custom Models

```
$ ./bin/datarobot lrs_operator install
```

### Delete Kubernetes

```
$ ./bin/datarobot kubernetes delete
```
