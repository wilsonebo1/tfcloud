# VPC Installation

## Microsoft Azure
### Azure Blob Service as backend storage

`FILE_STORAGE_PREFIX`: Represents the prefix after the root path applied to all paths in the file storage medium.

`FILE_STORAGE_TYPE`: To use Azure Blob service set to `azure_blob`.

Note: For existing DataRobot installations, when `FILE_STORAGE_TYPE` configuration setting gets changed to `azure_blob`, DataRobot will not be able to access previously existing files. In order to continue using them, existing data must be manually migrated into Microsoft Blob Storage. Microsoft offers a few options to perform this migration, described in the [Storage migration FAQ](https://docs.microsoft.com/en-us/azure/storage/common/storage-migration-faq). See also [Get started with AzCopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10) and [Mount Blob storage as a file system on Linux](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-how-to-mount-container-linux).

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
For Dockerized installations, set to `s3` (Dockerized MinIO storage); you can also use `s3` for AWS storage.

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
#### Automatically configure the application using the `config.yaml`

`config.yaml` snippet:

```yaml
---
os_configuration:
  storage:
    use_google_storage_application: true
    google_storage_credentials_filename: /opt/tmp/creds.json

app_configuration:
  drenv_override:
    FILE_STORAGE_PREFIX: /data/
    FILE_STORAGE_TYPE: google
    GOOGLE_STORAGE_BUCKET: <bucket name>
```

`FILE_STORAGE_PREFIX`: Represents the prefix after the root path applied to all paths in the file storage medium.

`FILE_STORAGE_TYPE`: To use Google Cloud Storage set to `google`.

`GOOGLE_STORAGE_BUCKET` : Name of an existing bucket. DataRobot will store all files within this bucket.

This will take care of everything that is needed to install a configured version of DataRobot cluster
with Google Storage as a storage backend. Note that `google_storage_credentials_filename` needs to point to a
Google service account credentials JSON file *on the file system of the provisioner host*.
You can download it in the GCP console in `IAM & Admin -> Service accounts` and then upload it to the provisioner using
`scp` or any other preferred method.

Optionally, instead of uploading the file you can specify the file contents as base64-encoded string in the `config.yaml` directly and
it will be automatically processed and written to a file on each host's file system in the cluster.
Instead of specifying `google_storage_credentials_filename`you'll need to specify `google_storage_credentials_file_contents`. Example:

```yaml
---
os_configuration:
  storage:
    use_google_storage_application: true
    google_storage_credentials_file_contents: |
        CnsKICAidHlwZSI6ICJzZXJ2aWNlX2FjY291bnQiLAogICJwcm9qZWN0X2lkIjogInBpdm90YWwt
        cHVycG9zZS0yNTUyMTIiLAogICJwcml2YXRlX2tleV9pZCI6ICJlYzE2MzBmOWZjNDA1NjJmZDRl
        ODNmYjZjOWY1YzQ4MzVlOTdlMGJiIiwKICAicHJpdmF0ZV9rZXkiOiAiLS0tLS1CRUdJTiBQUklW
        QVRFIEtFWS0tLS0tXG5NSUlFdmdJQkFEQU5CZ2txaGtpRzl3MEJBUUVGQUFTQ0JLZ3dnZ1NrQWdF
        QUFvSUJBUURkWXduWm9sdnltK2xXXG5OSVBORWxLZzhFUFJzV0Y5ek9RZnhUdzFqeElxTlRtNHpN
        QXY1WWk0VVZPN1RLZ3R5SFRITVQ3am02WThXKzhpXG5LZTVLUWxWYmR5U0lhNjM5ci8wQ3U5Q0lU
        NGVlWTFpbHhvVmJwRVE5bzdCbFJta0d3TWlUWVZVZDBsa3NVenlyXG5NNzNZMjJtdDRRUkp1Tk9O
        aUZMYkR4VHRkT0FENFdiVjRVTzN0UHZ5cmI5cFpoYUE5WWh6VG45RTE2UFYvdWdIXG4vZmRZRndS
        RWtkQWl6S3FRbE1hZk1qWGpSbHZhWWdIUlVUdmw1NGFZVXRyTmR2MEgzYVpLNHNVTVdYekt2Z1lv
        XG5EMS9yaWRXaURxckR6eit0aWxUZ0hZQkhUbW5rc3pzVlI2UjhwSW1jVFBRY3R6Sk1oQm4rbHJ3
        WjhIQ2Q2MG9XXG5BcGdGakVCQkFnTUJBQUVDZ2dFQUNoOVBvWHhMY1BYUS91aUt5RE1ZeFJRSFBj
        eTY5T29MMmlvRi9UcnI3VE1lXG56d1RKbXNjSGI4b0VKcEcwTk5ld0F6V010eEowVU5reFAySWth
        NC9KNEZNN3YrTVFnd05yY1pjTnkxVzdrVEhnXG5xVC9BOURZNENvdHo4c1Y3NHR1b3NCaG9zR0xn
        UWVjU1pJK0tsQ0pBSER1b0d3alEzMjFHd0k1WmVodjRiQ1RwXG42S1pDRi9jenhKcXNIc0IxOWFX
        MXdrajE0YlZ3MXJJZWkydmUzZlNKY0NDU2FTazFtN3VLWnZ6V3VGRUhmSnl2XG5DbDgrUVR3WVFr
        Y3BxOFBKeTJsUWZIRVhZWE9NZ09pWFk2YThRMklrakpEOU1wMVcxYVYyai9TQ0Nvb0N6R05NXG5h
        cnJXWHJOQys3WUMwaTFZeDNoai90ZEdnTFg2NmZkOGJyZm1SWlovRXdLQmdRRDQzcWlmUGFQQkJX
        eUthZ3JoXG5GblJLZ3piUFVBM3UyTXlJSmxTZWtpeGJpWTEzQ0J4emh2dGRscHJ6aE4ydm9odlRR
        U3lBTndyaG1nK0ZTSmtHXG5aUDJMeE0wRDlqNnRLdTUvbFlLTFFpUkkyY3dyKzBsM08wRmQ2RDdG
        Y2t0SnBnRmFYMk4wQkRTTU1BaVF3ejhpXG5FYWhFcjNmQ3Z5RzdDMDl3VTh2NWhwU1lId0tCZ1FE
        anVzNU00NDFDU21HODRwbmwveSsvTXN3RnJIdnFpenVVXG5yUFRqTzNBZFZTTWt0c09neEF0SDdR
        U2pjenUxaFJ0SUQxOG9rYjM1ZjFEM0NVcXIvbEoyNWM1WThKc013VlhDXG5HVGwvaEg5bU1QOVNo
        U2ZQbjhDdVpsOGl6TTVpaksvWUZGRGFBbENwdmw1bVV0Vm5GcFB4dlF6Vk43MFpjc3NsXG5la0Fh
        WC9tYm53S0JnQXk3ajVMK0cxZXZ5RnJZakEveUR5Y1V5WVFYeTI2eDV0ejhZUTN2MnBjZ1ZYMkdp
        N1laXG5iTmpmOExPTzA2eTl0WUM4YitOcmJZSVhXTDN2OWV4TzFHNEhOcG9DU2ppZjNxM21YMVJ5
        b05xZFVnWGFDR3N5XG5PK2pyRGZNYUl1SDB2Vkw3V0dKQ0tOSVhUd2poQkdUZzFHUVhPaUJibVFV
        eDBmR2tSK1pQVFdEdkFvR0JBTVFLXG44c0lhT21iUTVhYlhaQ2t0TDR0blRWK3RCdGY0bUlmN0JL
        NEJZeGk5VEEyMUVGLzdwTUo4ZGp2SFhhVjhPdW9qXG40WVZwUWFQaFNIQUNIYmhHcmZNUkRqeGVs
        UHU4Qy9tV0FYdVhNcDFrbk1nTFBTUnRvRkFDYk8vbVk5MU93Nm8rXG5nd1BLYm1wU0thM29yVEdi
        ckN5MDFMRlExSWR0M1JnY1Q4Ymt6RnA5QW9HQkFLZktDb3EyZmp4MVJXeW5vZmpYXG5zOVhtbVRE
        RU12T0xObHRMcEovN2JRdjJLOTM0MUVWbEZlc0JzVEFuVlVwZWJxMTkwaEVWSjRpV0tiOGN2WEg0
        XG5wVlZNNlY5akM3MWVSWVRrZndVRldzYldjQTVjSmhhZkgrUGQvYjJ5M0pqdjBSMm5BQUQyL3BT
        Rlk5Y1pGRE45XG5BUUpHQUduVVYrWWZaQmdOOG4vd2E0RXdcbi0tLS0tRU5EIFBSSVZBVEUgS0VZ
        LS0tLS1cbiIsCiAgImNsaWVudF9lbWFpbCI6ICJsb2NhbC1kYXRhcm9ib3RAcGl2b3RhbC1wdXJw
        b3NlLTI1NTIxMi5pYW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsCiAgImNsaWVudF9pZCI6ICIxMDk1
        OTc4MDc0NjQ4NzkwMDg5MzQiLAogICJhdXRoX3VyaSI6ICJodHRwczovL2FjY291bnRzLmdvb2ds
        ZS5jb20vby9vYXV0aDIvYXV0aCIsCiAgInRva2VuX3VyaSI6ICJodHRwczovL29hdXRoMi5nb29n
        bGVhcGlzLmNvbS90b2tlbiIsCiAgImF1dGhfcHJvdmlkZXJfeDUwOV9jZXJ0X3VybCI6ICJodHRw
        czovL3d3dy5nb29nbGVhcGlzLmNvbS9vYXV0aDIvdjEvY2VydHMiLAogICJjbGllbnRfeDUwOV9j
        ZXJ0X3VybCI6ICJodHRwczovL3d3dy5nb29nbGVhcGlzLmNvbS9yb2JvdC92MS9tZXRhZGF0YS94
        NTA5L2xvY2FsLWRhdGFyb2JvdCU0MHBpdm90YWwtcHVycG9zZS0yNTUyMTIuaWFtLmdzZXJ2aWNl
        YWNjb3VudC5jb20iCn0K

app_configuration:
  drenv_override:
    FILE_STORAGE_PREFIX: /data/
    FILE_STORAGE_TYPE: google
    GOOGLE_STORAGE_BUCKET: <bucket name>
```

#### Manually configure DataRobot using `drenv_override`

To perform the configuration manually, e.g. in case `sftp`/`rsync` between hosts is not possible and the installer will not be able to
automatically distribute the Google Credentials file between the hosts in the cluster, follow the example below:

```yaml
 app_configuration:
   drenv_override:
     FILE_STORAGE_PREFIX: /data/
     FILE_STORAGE_TYPE: google
     GOOGLE_STORAGE_BUCKET: <bucket name>
     GOOGLE_STORAGE_APPLICATION_CREDENTIALS: <path to keyfile>
 ```

`FILE_STORAGE_PREFIX`: Represents the prefix after the root path applied to all paths in the file storage medium.

`FILE_STORAGE_TYPE`: To use Google Cloud Storage set to `google`.

`GOOGLE_STORAGE_BUCKET` : Name of an existing bucket. DataRobot will store all files within this bucket.

`GOOGLE_STORAGE_APPLICATION_CREDENTIALS` : Path to a google service account credentials file, must be present on all cluster nodes.

`GOOGLE_STORAGE_KEYFILE_CONTENTS` : The google service account credentials keyfile contents, base64 encoded. May be specified in place of `GOOGLE_STORAGE_APPLICATION_CREDENTIALS`; this is more convenient than copying files to all cluster nodes, but it is also less secure.
