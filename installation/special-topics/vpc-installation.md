# VPC Installation

## Microsoft Azure
### Azure Blob Service as backend storage

`FILE_STORAGE_PREFIX`: Represents the prefix after the root path applied to all paths in the file storage medium.

`FILE_STORAGE_TYPE`: To use Azure Blob service set to `azure_blob`.

`config.yaml` snippet:

```yaml
---
app_configuration:
  drenv_override:
    FILE_STORAGE_TYPE: azure_blob
    AZURE_BLOB_STORAGE_CONTAINER_NAME: <blob_container_name>
    AZURE_BLOB_STORAGE_ACCOUNT_NAME: <storage_account_name>
    AZURE_BLOB_STORAGE_ACCOUNT_KEY: <storage_account_secret_key>
```

`AZURE_BLOB_STORAGE_CONTAINER_NAME` : Name of existing container. DataRobot will store all files within this container.

`AZURE_BLOB_STORAGE_ACCOUNT_NAME` : Name of existing Azure Blob Storage Account.

`AZURE_BLOB_STORAGE_ACCOUNT_KEY` : Secret key string for accessing `AZURE_BLOB_STORAGE_ACCOUNT_NAME`. Refer to the [Azure documentation](https://docs.microsoft.com/en-us/azure/storage/common/storage-configure-connection-string) to create the account key.

`AZURE_BLOB_STORAGE_CONNECTION_STRING` : An alternative way of configuring access. Instead of filling AZURE_BLOB_STORAGE_ACCOUNT_NAME and AZURE_BLOB_STORAGE_ACCOUNT_KEY values, you can use only this value. Refer to the Azure [view and copy a connection string](https://docs.microsoft.com/en-us/azure/storage/common/storage-configure-connection-string?toc=%2fazure%2fstorage%2fblobs%2ftoc.json#view-and-copy-a-connection-string). This allows you to connect to not only to Azure Blob Storage itself, but to various storage emulators or API compatible 3rd-party services.

#### Authenticate DataRobot using Service Principal credentials

Instead of using a shared key, DataRobot can connect to the Azure Blob Service using Service Principal credentials. Refer to Microsoft's [How to: Use the portal to create an Azure AD application and service principal that can access resources](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal).That document will explain how to register a new application, get an Application (Client) and Tenant IDs, and generate a secret key string.  These values must be set in `config.yaml` as AZURE_CLIENT_ID, AZURE_TENANT_ID, and AZURE_CLIENT_SECRET. Your application must be assigned as `Storage Blob Data Contributor` to Storage Account.

`config.yaml` snippet:

```yaml
---
app_configuration:
  drenv_override:
    FILE_STORAGE_TYPE: azure_blob
    AZURE_BLOB_STORAGE_CONTAINER_NAME: <blob_container_name>
    AZURE_BLOB_STORAGE_ACCOUNT_NAME: <storage_account_name>
    AZURE_TENANT_ID: <azure_tenant_id>
    AZURE_CLIENT_ID: <azure_client_id>
    AZURE_CLIENT_SECRET: <service_principal_secret_key>
```

#### Grant DataRobot virtual machine access to an Azure Storage container

Granting DataRobot access allows you to avoid using any kind of credentials directly. See the Microsoft documentation to learn [how to grant access](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/tutorial-linux-vm-access-storage#grant-your-vm-access-to-an-azure-storage-container) to your storage account for a specific virtual machine or virtual machine scale set. The `Storage Blob Data Contributor` role is required to read and write data into the container.

`config.yaml` snippet:

```yaml
---
app_configuration:
  drenv_override:
    FILE_STORAGE_TYPE: azure_blob
    AZURE_BLOB_STORAGE_CONTAINER_NAME: <blob_container_name>
    AZURE_BLOB_STORAGE_ACCOUNT_NAME: <storage_account_name>
```

## AWS
### File storage configuration changes

`FILE_STORAGE_PREFIX`: Represents the prefix applied to all paths in the file storage medium after the root path.

`FILE_STORAGE_TYPE`: For Cloudera installations set to `hdfs` (WebHDFS storage driver) or `hdfs3` (native HDFS storage driver).
For Dockerized installations, set to `gluster_api` (Dockerized Gluster storage) or `s3` (AWS S3 storage).

`config.yaml` snippet:

```yaml
---
app_configuration:
  drenv_override:
    AWS_ACCESS_KEY_ID: <key>
    AWS_SECRET_ACCESS_KEY: <redacted>
    FILE_STORAGE_PREFIX: /data/
    FILE_STORAGE_TYPE: s3
    MULTI_PART_S3_UPLOAD: false
    S3_BUCKET: <bucket>
    S3_CALLING_FORMAT: OrdinaryCallingFormat
    S3_HOST: s3.us-east-1.amazonaws.com
    S3_IS_SECURE: true
    S3_PORT: 443
```

If using `s3` storage type, you must addtionally set

`S3_BUCKET` : Name of the S3 bucket to store DataRobot application files in. Your access key ID must belong to an account that has write, read, and list permissions on this bucket.

`S3_CALLING_FORMAT`: Defaults to SubdomainCallingFormat. Valid values are limited to: SubdomainCallingFormat, VHostCallingFormat, OrdinaryCallingFormat and ProtocolIndependentOrdinaryCallingFormat

`S3_HOST`: ip or hostname of the S3 appliance, no longer optional field post V4 implementation

You may addtionally set the `S3_REGION` variable if you want to explicitly specify which region you run on, or if you are using a storage provider which provides an S3-compatible API.

`S3_IS_SECURE`: Whether or not the service is using HTTPS - The True value, which is the Default, has only been tested in AWS S3

`S3_PORT`: The port on which the S3 service is running

DataRobot recommends using AWS IAM roles attached to your instances to authenticate with S3 storage.
If you prefer to use keys, or are connecting to an S3-compatible API, you will additionally need to add your credentials as environment variables:

`AWS_ACCESS_KEY_ID` : Access key ID for the account you want to use to connect to S3 storage.
`AWS_SECRET_ACCESS_KEY` : Secret access key for authenticating your AWS account.


### IAM role policy settings

Example of IAM role policy for S3 access.

Note: the resource path composed as concatenation of `S3_BUCKET` and `FILE_STORAGE_PREFIX` values.
In this example `S3_BUCKET=vpc_installation`:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessToProduction",
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject",
                "s3:Get*",
                "s3:PutObject",
                "s3:ReplicateDelete",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::vpc_installation/data/*"
            ]
        },
        {
            "Sid": "AllowListBucketsProduction",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:ListBucketVersions",
                "s3:ListAllMyBuckets"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
```

### S3 Ingestion
To enable data ingestion from private objects stored in S3, see the [AWS S3 Ingest](./ingest-from-aws-s3-storage.md) guide.

### Allowing unverified SSL
If there is a customer environment that needs to connect to their own object storage using unverified SSL, add this to the config.yaml:

```yaml
---
app_configuration:
  drenv_override:
    S3_VALIDATE_CERTS: False
    ALLOW_SELF_SIGNED_CERTS: True
```

## Google Cloud Storage
### Google Cloud Storage as backend storage

`FILE_STORAGE_PREFIX`: Represents the prefix after the root path applied to all paths in the file storage medium.

`FILE_STORAGE_TYPE`: To use Google Cloud Storage set to `google`.

`config.yaml` snippet:

```yaml
---
app_configuration:
  drenv_override:
    FILE_STORAGE_PREFIX: /data/
    FILE_STORAGE_TYPE: google
    GOOGLE_STORAGE_BUCKET: <bucket name>
    GOOGLE_STORAGE_APPLICATION_CREDENTIALS: <path to keyfile>
```

`GOOGLE_STORAGE_BUCKET` : Name of an existing bucket. DataRobot will store all files within this bucket.

`GOOGLE_STORAGE_APPLICATION_CREDENTIALS` : Path to a google service account credentials file, must be present on all cluster nodes.

`GOOGLE_STORAGE_KEYFILE_CONTENTS` : The google service account credentials keyfile contents, base64 encoded. May be specified in place of `GOOGLE_STORAGE_APPLICATION_CREDENTIALS`; this is more convenient than copying files to all cluster nodes, but it is also less secure.
