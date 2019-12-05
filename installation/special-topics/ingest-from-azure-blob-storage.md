# Data ingestion from Microsoft Azure Blob Storage

On-premise installations of DataRobot support ingestion of Azure Blob Storage objects from private containers.

Once configured correctly, Azure Blob Storage objects are accessible using links as `azure_blob://<container-name>/<file-name.csv>`.

## DataRobot application configuration
 
The DataRobot application can access objects within a single Storage Account that is specified in `AZURE_BLOB_STORAGE_ACCOUNT_NAME`.
**NOTE**:  It is not necessary to set the `AZURE_BLOB_STORAGE_ACCOUNT_NAME` once you are using `AZURE_BLOB_STORAGE_CONNECTION_STRING` (refer to [VPC Installation](./vpc-installation.md) for more information)

There are three supported ways of authenticating the DataRobot application so that it can access Azure Storage:

- using Shared Key credentials
- using Service Principal credentials
- granting the `Storage Blob Data Contributor` IAM role to the entire Virtual Machine.

This should be configured in cluster's config.yaml (see the [VPC Installation](./vpc-installation.md) guide for details).

**NOTE**: Attaching Azure Blob Storage to the DataRobot application deployed outside of Azure Cloud is possible only when using either Shared Key or Service Principal authentication.
