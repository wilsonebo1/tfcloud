# Preparing Google Cloud account

GCP account should be prepared before run installation. 

To prepare account use has to have the **AdministratorAccess** in the account and you should have 
a public domain name in your possession. We will reference it as `<your_domain>`

As a result of the following step you get:
* ServiceAccount
* Cluster name
* VPC
* Cloud NAT
* SSH key pair for VM
* Public DNS Zone in the CloudDNS
* Firewall rules: 
  * **allow-all-internal** 
  * **Calico-ipip**
  
## Choose cluster name

You should choose the kubernetes cluster name we will use for all resources. 
It should be unique per Datarobot installation since we support multiple kubernetes clusters 
(in the same or different cloud provider accounts) to be integrated with Datarobot. 
In this documentation, it will be referenced as `<cluster_name>`
`<cluster_name>` can not be longer than 24 characters and must be valid Domain Zone (contains ASCII 
letters, digits, and hyphens (a-z, A-Z, 0-9, -), but not starting or ending with a hyphen).

## Account Requirements    

### VPC

The GoogleCloud account should have at least one VPC, it can be the “default” VPC. 
It also can be created as a new one: [Using VPC networks: Creating a custom mode network](https://cloud.google.com/vpc/docs/using-vpc)

* Go to the VPC networks page in the Google Cloud Platform Console: 
[GO TO THE VPC NETWORKS PAGE](https://console.cloud.google.com/networking/networks/list) and select 
project where VPC will be created or use current GCP project
* Click **Create VPC network**.
* Enter a **Name** for the network. (`datarobot-kubernetes`)
* Choose **Custom** for the **Subnet creation mode**.
* In the **New subnet** section, specify the following configuration parameters for a subnet:
    * Provide a **Name** for the subnet. (`subnet1`)
    * Select a **Region**. (`us-east1`)
    * Enter an **IP address range**. This is the primary IP range for the subnet. (`10.0.0.0/21`)
    * **Private Google access**:  do not change
    * **Flow logs**: do not change
    * Click **Done**.
* Click **Create**.

### Cloud NAT

**Cloud NAT gateway** should be created and attached to the VPC if any Cloud NAT gateway does not 
exist, it **must be created**: [Using Cloud NAT: Create NAT(Simple configuration)](https://cloud.google.com/nat/docs/using-nat)

* Go to the Cloud NAT page in the Google Cloud Platform Console. GO_TO_THE_CLOUD_NAT_PAGE
* Click **Create NAT gateway**.
* Enter a **Gateway name**. (`datarobot-kubernetes`)
* Choose a **VPC network**. (`datarobot-kubernetes`)
* Set the **Region** for the NAT gateway. (`us-east1`)
* Select or create a **Cloud Router** in the region.
    * Choose **Create**
    * Enter Name (`datarobot-kubernetes-router`)
    * Choose **Create**
* Click **Logging, minimum ports, timeout** to open that section.
* Click **Create**.

### SSH key pair

If you don't have an existing private SSH key file and a matching public SSH key file that you can use, 
generate a new SSH key. If you want to use an existing SSH key, locate the public SSH key file.

On Linux or macOS workstations, you can generate a key by using the `ssh-keygen` tool.

Open a terminal on your workstation and use the `ssh-keygen` command to generate a new key. 
Specify the `-C` flag to add a comment with your username.
```
ssh-keygen -t rsa -f ~/.ssh/<cluster-name> -C centos
```

And hit enter twice. Where:

* `<cluster-name>` is the name that you want to use for your SSH key files. 
This command will produce two files `~/.ssh/<cluster-name>` and `~/.ssh/<cluster_name>.pub`
* `centos` is the username for the user connecting to the instance.

Restrict access to your private key so that only you can read it and nobody can write to it.
```
chmod 400 ~/.ssh/<cluster-name>
```

### Firewall rules

**Two firewall rules** must be added to GoogleCloud project if they don’t exist yet: 
[Configuring firewall rules: GCP firewall rules](https://cloud.google.com/vpn/docs/how-to/configuring-firewall-rules)

Create firewall rule for **calico**:

* Go to the **Firewall Rules** page in the Google Cloud Platform Console. [FIREWALL RULES PAGE](https://console.cloud.google.com/networking/firewalls)
* Click **Create firewall rule**.
* Populate the following fields:
    * **Name**: `calico-ipip` 
    * **Network**: `{{ PUT_HERE_VPC_NAME }}` (`datarobot-kubernetes`, for example)
    * **Priority**: 1000
    * **Direction**: Ingress
    * **Action on match**: allow
    * **Targets**: All instances in the network
    * **Source filter**:  IP ranges
    * **Source IP ranges**: `{{ PUT_HERE_VPC_SUBNET_CIDR }}` (`10.0.0.0/8`)
    * **Specified protocols and ports**: 
        * Choose **Other protocols** 
        * Enter `ipip`
* Click **Create**

Create a firewall rule for allowing **internal traffic flow**:

* Go to the **Firewall Rules** page in the Google Cloud Platform Console. 
[FIREWALL RULES PAGE](https://console.cloud.google.com/networking/firewalls)
* Click **Create firewall rule**.
* Populate the following fields:
    * **Name**: allow-all-internal
    * **Network**: `{{ PUT_HERE_VPC_NAME }}` (`datarobot-kubernetes`)
    * **Priority**:  1000
    * **Direction**:  Ingress
    * **Action on match**:  allow
    * **Targets**: All instances in the network
    * **Source filter**:  IP Ranges
    * **Source IP ranges**: `{{ PUT_HERE_VPC_SUBNET_CIDR }}` (`10.0.0.0/8`)
    * **Protocols and ports**:  Allow all
* Click **Create**

### Domain Zones Requirements

Kubernetes **requires 2 DNS zones** (1 Public and 1 Private)  in the account to work. 

#### Private DNS zone

It will be created automatically. 

#### Public DNS zone

Public DNS zone in Google Cloud DNS must be with enabled [DNSSEC](https://cloud.google.com/dns/docs/dnssec).  

Public DNS Zone in Google Cloud DNS can be manually created: 
[Cloud DNS Documentation: Create a managed public zone](https://cloud.google.com/dns/docs/quickstart). 
**Before doing the next steps, you should have domain that you own `<your_domain>`**. 

* Go to the Create a DNS zone page in the GCP Console. [GO_TO_THE_CREATE_A_DNS_ZONE_PAGE](https://console.cloud.google.com/networking/dns/zones/~new)
* Choose the **Public** for the **Zone type**.
* Enter `<your_public_dns_zone_name>` (`datarobotk8s`) for the **Zone name**.
* Enter a **DNS name** suffix for the zone using a `<your_domain>` that you **own**. 
Note, it should be **available** and fully functional domain.
* Under **DNSSEC**, keep the On setting selected.
* Click **Create**.

The **Zone details** page is displayed. 
**Note** that default **NS** and **SOA** records have been created for you.

**Delegate** the public zone management:

With its nameservers(**NS records**) in the place where the `<your_domain>` zone exists

* Go to the **Cloud DNS** zone page in the **GCP Console**. [GO_TO_THE_CLOUD_DNS_PAGE](https://console.cloud.google.com/net-services/dns/zones) 
* Choose **Public DNS** zone which must be delegated and copy **all Data** from **NS** field
* Choose a `datarobotk8s` zone in the list
* Write down the `datarobotk8s` domain and it’s **NS** records

Now public DNS zone can be delegated to another placeholder(GoDaddy, Route53 or any else) in any 
preferable way: [Cloud DNS Documentation: Delegated subzones](https://cloud.google.com/dns/docs/overview)

### Permissions 

Set of permissions required to install Kubernetes

#### Service Account
Operator will need service account with [assigned editor role](https://cloud.google.com/iam/docs/understanding-roles#role_types). 
ServiceAccount credentials **key** must be saved as a ***.JSON** file. 
[Creating and managing service accounts: Creating a service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts)

* Open the **Service Accounts** page in the Cloud Console. [OPEN_THE_SERVICE_ACCOUNTS_PAGE](https://console.cloud.google.com/iam-admin/serviceaccounts)
* Click **Select a project**.
* Select your project and click **Open**.
* Click **Create Service Account**.
* Enter a service account name (`datarobot-kubernetes-account`), an optional description
* Choose **Create**
* Select a role you wish to grant to the service account: 
    * Next step is to click the drop-down list under **Role(s)** for the service account that you 
    want to edit.
    * Select the **`Editor`** role to apply to the service account.
* Click **Continue**
* Choose **Create Key**
* Choose **JSON**
* Choose **Create**
* Save json file in a safe place
