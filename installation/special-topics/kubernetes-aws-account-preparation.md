# Preparing AWS account

AWS account should be prepared before run installation. 

To prepare account user has to have the AdministratorAccess policy in the account and you should have 
a public domain name in your possession. We will reference it as *<your_domain>*
 
As a result of the following step you get:
* Cluster name
* 3 VPC subnets IDs
* EC2 Key Pair (saved key file)
* CentOS 7 AMI subscription
* Private DNS Zone in the Route53
* Public DNS Zone in the Route53 (domain name and Zone ID) 
* Set of IAM permissions (and their arn)

## Choose cluster name

You should choose the kubernetes cluster name we will use for all resources. 
It should be unique per Datarobot installation since we supporting multiple kubernetes clusters 
(in the same or different cloud provider accounts) to be integrated with Datarobot. 
In this documentation, it will be referenced as `<cluster_name>` 
`<cluster_name>` can not be longer than 24 characters and must be valid Domain Zone 
(contains ASCII letters, digits, and hyphens (a-z, A-Z, 0-9, -), but not starting or ending with a 
hyphen).

## Account Requirements

The account must have at least 3 different subnets in VPC.

There should be created ssh EC2 Key Pairs for instances and you should have the key file 
before installation. [Creating a Key Pair Using Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair) :
* Open the Amazon EC2 console at https://console.aws.amazon.com/ec2/.
* In the navigation pane, under NETWORK & SECURITY, choose **Key Pairs**.
* Choose **Create Key Pair**.
* For Key pair name, enter a name for the new key pair `<cluster_name>`, and then choose to **Create**.
* The private key file is automatically downloaded by your browser. 
The base file name is `<cluster_name>.pem`. Save the private key file in a safe place.
* Do `chmod 400 <cluster_name>.pem` 
! If you do not set these permissions, then you cannot connect to your instance using this key pair. 

## AMI

Official CentOS 7 AMI subscription should be purchased in the account. 
You may use [this tutorial](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/paid-amis.html#using-paid-amis-purchasing-paid-ami) or following the next steps:

* Open the Amazon EC2 console at https://console.aws.amazon.com/ec2/
* From the Amazon EC2 dashboard, choose **Launch Instance**
* On the **Choose an Amazon Machine Image (AMI)** page, choose the **AWS Marketplace** category 
on the left. Type `CentOS Linux 7 x86_64 HVM EBS *` in the search bar and hit Enter. 
Choose **Select** to choose the first CentOS 7 product on the list.
* A dialog displays an overview of the product you've selected. 
You can view the pricing information, as well as any other information that the vendor has provided. 
When you're ready, choose **Continue**. On new accounts, this step could require some time to wait 
for confirmation. 
* On the **Choose an Instance Type** page, select the `m5.xlarge` of the instance to launch. 
When you're done, choose **Next: Configure Instance Details**.
* Choose **Next** until you reach the **Configure Security Group** page.
* Choose **Review and Launch**.
* On the **Review Instance Launch** page, check the details of the AMI from which you're about to 
launch the instance, as well as the other configuration details you set up in the wizard. 
When you're ready, choose **Launch** to select key pair `<cluster_name>`, and launch your instance.
* Choose **View Instances**.
* Wait until instance became **Running**.
* Terminate instance with **Actions -> Instance State -> Terminate**. 

## Domain Zones Requirements

Kubernetes requires 2 DNS zones (1 Public and 1 Private)  in the account to work. 
As a result of these steps, you should create both of them and get **Public DNS Zone** _name_ and _ID_.  

### Private DNS Zone

* Make sure your VPC has **enableDnsHostnames** and **enableDnsSupport** set to **True**. 
To update those settings follow the [Viewing and Updating DNS Support for Your VPC](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html#vpc-dns-updating).
* Sign in to the **AWS Management Console** and open the **Route53** console at https://console.aws.amazon.com/route53/ .
* Choose **Hosted Zones** in the navigation pane.
* Choose **Create Hosted Zone**.
* In the **Create Private Hosted Zone** pane, enter a domain name `<cluster_name>.aws` and, 
optionally, a comment.
* In the **Type** list, choose **Private Hosted Zone for Amazon VPC**.
* In the **VPC ID** list, choose the VPC that you want to associate with the hosted zone.
* Click **Create**.

### Public DNS Zone

* Sign in to the **AWS Management Console** and open the **Route 53** console at https://console.aws.amazon.com/route53/.
* Choose **Hosted Zones** in the navigation pane.
* Choose **Create Hosted Zone**.
* In the **Create Private Hosted Zone** pane, enter a domain name `<cluster_name>.<your_domain>` and, 
optionally, a comment.
* In the **Type** list, choose **Public Hosted Zone**.
* Click **Create**.
* Save **Hosted Zone ID** it would be used later as `<public_zone_id>`

Delegate Zone management. Use [this article](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html), or follow the steps:

* On the **Hosted Zones page**, choose the radio button (not the name) for the hosted zone.
* In the right pane, make note of the four servers listed for **Name Servers**. 
* Using the method provided by the DNS service of the parent domain, 
add NS records for the subdomain to the zone file for the parent domain. In these NS records, 
specify the four Route 53 name servers that are associated with the hosted zone that you created.

Write down the **Domain Name** and **Hosted Zone ID**. We will reference them as `<public_domain_name>` 
and `<public_zone_id>`


## IAM configuration 

Kubernetes cluster requires a set of permissions for correct work. WRITE/CHANGE access 
**limited to resources created for cluster only** and the READ and LIST permissions given to the 
specific resources.

These are a list of the instance profiles and roles that should be present in the account:
* `<cluster_name>`-k8s-etcd
* `<cluster_name>`-k8s-master
* `<cluster_name>`-k8s-worker
* `<cluster_name>`-k8s-base
* `<cluster_name>`-k8s-autoscaler
* `<cluster_name>`-k8s-cert-manager
* `<cluster_name>`-k8s-ec2-srcdst
* `<cluster_name>`-k8s-external-dns

### <cluster_name>-k8s-etcd

* Sign in to the **AWS Management Console** and open the Identity and **Access Management (IAM)** at 
https://console.aws.amazon.com/iam/home
* Choose **Role -> Create role**
* Сhoose **EC2** from the list
* Choose **Next** until you reach the **Review**
* Enter **`<cluster_name>`-k8s-etcd** as role name
* Choose **Create role**
* Get back to newly created role
* Choose **Add Inline Policy**
* Select JSON tab
* Replace Text with the following JSON:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        }
    ]
}
```
* Choose **Review Policy**
* Enter **`<cluster_name>`-k8s-etcd** as policy name
* Choose **Create Policy**
* **Save Role ARN, we will reference it as `<etcd_role_arn>`**

### <cluster_name>-k8s-master

* Sign in to the **AWS Management Console** and open the **Identity and Access Management (IAM)** 
at https://console.aws.amazon.com/iam/home
* Choose **Role -> Create role**
* Сhoose **EC2** from the list
* Choose **Next** until you reach the *Review**
* Enter **`<cluster_name>`-k8s-master** as role name
* Choose **Create role**
* Get back to newly created role
* Choose **Add Inline Policy**
* Select JSON tab
* Replace Text with the following JSON:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:Get*",
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:*SecurityGroup",
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:*Tags",
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:*Volume",
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:ResourceTag/KubernetesCluster":"<cluster-name>"
                }
            }
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        }
    ]
}
```
* Choose **Review Policy**
* Enter **`<cluster_name>`-k8s-master** as policy name
* Choose **Create Policy**
* **Save Role ARN, we will reference it as `<master_role_arn>`**

### <cluster_name>-k8s-worker

* Sign in to the **AWS Management Console** and open the **Identity and Access Management (IAM)** at 
https://console.aws.amazon.com/iam/home
* Choose **Role -> Create role**
* Сhoose **EC2** from the list
* Choose **Next** until you reach the **Review**
* Enter **`<cluster_name>`-k8s-worker** as role name
* Choose **Create role**
* Get back to newly created role
* Choose **Add Inline Policy**
* Select JSON tab
* Replace Text with the following JSON:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:AttachVolume",
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:DetachVolume",
            "Resource": "*"
        }
    ]
}
```

* Choose **Review Policy**
* Enter **`<cluster_name>`-k8s-worker** as policy name
* Choose **Create Policy**
* **Save Role ARN, we will reference it as `<worker_role_arn>`**

### <cluster_name>-k8s-base

* Sign in to the **AWS Management Console** and open the **Identity and Access Management (IAM)** at 
https://console.aws.amazon.com/iam/home
* Choose **Role -> Create role**
* Сhoose **EC2** from the list
* Choose **Next** until you reach the **Review**
* Enter **`<cluster_name>`-k8s-base** as role name
* Choose **Create role**
* Get back to newly created role
* Choose **Add Inline Policy**
* Select JSON tab
* Replace Text with the following JSON:
```
{ 
 "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Deny",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
```
* Choose **Review Policy**
* Enter `<cluster_name>`**-k8s-base** as policy name
* Choose **Create Policy**
* Choose **Trust Relationship** tab
* Choose **Edit Trust Relationships**
* Enter the following JSON to the **Policy Document** field  (replace `<etcd_role_arn>`, 
`<worker_role_arn>`,  `<master_role_arn>` with the values from the previous steps!):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "<etcd_role_arn>",
          "<worker_role_arn>",
          "<master_role_arn>"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```
* Choose **Update Trust Policy**

### <cluster_name>-k8s-cert-manager

* Sign in to the **AWS Management Console** and open the **Identity and Access Management (IAM)** at 
https://console.aws.amazon.com/iam/home
* Choose **Role -> Create role**
* Сhoose **EC2** from the list
* Choose **Next** until you reach the **Review**
* Enter **`<cluster_name>`-k8s-cert-manager** as role name
* Choose **Create** role
* Get back to newly created role
* Choose **Add Inline Policy**
* Select JSON tab
* Replace Text with the following JSON (replace `<public_zone_id>` with the value from the 
previous steps!):
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
         "Sid": "",
          "Effect": "Allow",
            "Action": "route53:GetChange",
            "Resource": "arn:aws:route53:::change/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": "arn:aws:route53:::hostedzone/<public_zone_id>"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "route53:ListHostedZonesByName",
            "Resource": "*"
        }
    ]
}
```
* Choose **Review Policy**
* Enter **`<cluster_name>`-k8s-cert-manager** as policy name
* Choose **Create Policy**
* Enter the following JSON to the **Policy Document** field  (replace `<etcd_role_arn>`,
 `<worker_role_arn>`, `<master_role_arn>` with the values from the previous steps!):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "<etcd_role_arn>",
          "<worker_role_arn>",
          "<master_role_arn>"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```
* Choose **Update Trust Policy**

### <cluster_name>-k8s-ec2-srcdst

* Sign in to the **AWS Management Console** and open the **Identity and Access Management (IAM)** 
at https://console.aws.amazon.com/iam/home
* Choose **Role -> Create role**
* Сhoose **EC2** from the list
* Choose **Next** until you reach the **Review**
* Enter **`<cluster_name>`-k8s-ec2-srcdst** as role name
* Choose **Create role**
* Get back to newly created role
* Choose **Add Inline Policy**
* Select JSON tab
* Replace Text with the following JSON:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:ModifyInstanceAttribute",
            "Resource": "*"
        }
    ]
}
```
* Choose **Review Policy**
* Enter **`<cluster_name>`-k8s-ec2-srcdst** as policy name
* Choose **Create Policy**
* Enter the following JSON to the Policy Document field  (replace `<etcd_role_arn>`, 
`<worker_role_arn>`,  `<master_role_arn>` with the values from the previous steps!):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "<etcd_role_arn>",
          "<worker_role_arn>",
          "<master_role_arn>"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```
* Choose **Update Trust Policy**

### <cluster_name>-k8s-external-dns

* Sign in to the **AWS Management Console** and open the **Identity and Access Management (IAM)** at 
https://console.aws.amazon.com/iam/home
* Choose **Role -> Create role**
* Сhoose **EC2** from the list
* Choose **Next** until you reach the **Review**
* Enter **`<cluster_name>`-k8s-external-dns** as role name
* Choose **Create role**
* Get back to newly created role
* Choose **Add Inline Policy**
* Select JSON tab
* Replace Text with the following JSON (replace `<public_zone_id>` with the value from the previous
 steps!):
 ```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": "arn:aws:route53:::hostedzone/<public_zone_id>"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "route53:ListResourceRecordSets",
                "route53:ListHostedZones"
            ],
            "Resource": "*"
        }
    ]
}
```
* Choose **Review Policy**
* Enter **`<cluster_name>`-k8s-external-dns** as policy name
* Choose **Create Policy**
* Enter the following JSON to the Policy Document field (replace `<etcd_role_arn>`, 
`<worker_role_arn>`,  `<master_role_arn>` with the values from the previous steps!):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "<etcd_role_arn>",
          "<worker_role_arn>",
          "<master_role_arn>"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```
* Choose **Update Trust Policy**
