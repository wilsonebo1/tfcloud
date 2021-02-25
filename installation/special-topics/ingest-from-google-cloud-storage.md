# Data ingestion from Google Cloud Storage

On Premise installations of DataRobot support ingestion of Google Cloud Storage objects using either of the two methods described below.

Once configured correctly Google Cloud Storage objects are accessible using links as `gs://<bucket-name>/<file-name.csv>`.


## Ingest From Google Cloud Storage Using A Service Account

The first option for data ingest from Google Cloud Storage uses the native storage protocols.

**Note**: The directions here are intended for when google storage is only used for data ingest.
If google storage is to be used for data ingest and backend storage, both features share the same service account configuration,
and the directions for configuring backend storage should be used instead.

There are several ways to configure DataRobot to access Google Cloud Storage depending on how credentials will be supplied.
Refer to the description with each subsection below to determine which is the best fit for a particular installation.

The following values are common and must be set for all methods of supplying credentials:

`ENABLE_GS_INGESTION` : Must be `True` to enable google storage ingest using native protocols.

`GOOGLE_STORAGE_CREDENTIALS_SOURCE` : Specifies how the credentials will be provided to DataRobot, see the examples below.

For the examples using a "keyfile", follow [these instructions](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#iam-service-account-keys-create-console)
to create and download a JSON key file for the appropriate service account.


### Configure the application running in GCE using the `config.yaml`

Google can provide ["Application Default Credentials (ADC)"](https://cloud.google.com/docs/authentication/production)
to software running on a GCE instance.
The GCE instance must be [configured with a default service account](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances)
in order for this to work.
This method is the most convenient and secure because google will manage all credentials outside the
instance, so plain-text credentials will not be stored.

Example `config.yaml` snippet:

```yaml
---
os_configuration:
  google_cloud:
    use_google_cloud_application: true
    google_credential_source: adc

app_configuration:
  drenv_override:
    FILE_STORAGE_PREFIX: data/
    FILE_STORAGE_TYPE: google
    GOOGLE_STORAGE_BUCKET: your-google-storage-bucket
    ENABLE_GS_INGESTION: True
```

`ENABLE_GS_INGESTION` : Must be `True` to enable google storage ingest using native protocols.

### Configure the application with base64 encoded credentials using the `config.yaml`

To avoid having to manually copy the keyfile to all nodes in the cluster, the base64-encoded contents
can be set in the configuration and DataRobot will create temporary files where needed.

Example `config.yaml` snippet:

```yaml
---
os_configuration:
  google_cloud:
    use_google_cloud_application: true
    google_credential_source: contents
    google_credential_keyfile_contents: |
        CnsKICAidHlwZSI6ICJzZXJ2aWNlX2FjY291bnQiLAogICJwcm9qZWN0X2lkIjogInBpdm90YWwt
        cHVycG9zZS0yNTUyMTIiLAogICJwcml2YXRlX2tleV9pZCI6ICJlYzE2MzBmOWZjNDA1NjJmZDRl
        ......
        YWNjb3VudC5jb20iCn0K

app_configuration:
  drenv_override:
    FILE_STORAGE_PREFIX: data/
    FILE_STORAGE_TYPE: google
    GOOGLE_STORAGE_BUCKET: your-google-storage-bucket
    ENABLE_GS_INGESTION: True
```

`ENABLE_GS_INGESTION` : Must be `True` to enable google storage ingest using native protocols.

### Configure DataRobot with a manually distributed credentials file using `drenv_override`

The keyfile must be manually distributed to the same path on all nodes, and this path must be supplied in the configuration.

Example `config.yaml` snippet:

```yaml
os_configuration:
  google_cloud:
    use_google_cloud_application: true
    google_credential_source: path
    google_credential_keyfile_path: /opt/datarobot/etc/credentials/<keyfile.json>

app_configuration:
  drenv_override:
    FILE_STORAGE_PREFIX: data/
    FILE_STORAGE_TYPE: google
    GOOGLE_STORAGE_BUCKET: your-google-storage-bucket
    ENABLE_GS_INGESTION: True
 ```

`ENABLE_GS_INGESTION` : Must be `True` to enable google storage ingest using native protocols.

## Ingest From Google Cloud Storage Using S3 Compatibility

The second configuration option for data ingest from Google Cloud Storage relies on Google Cloud Storage implementation of AWS S3 protocol, also known as Interoperability feature.

Follow [these directions](https://cloud.google.com/storage/docs/migrating#keys) to enable the interoperability feature and create an Access Key with a Secret.

Example `config.yaml` snippet:

```yaml
app_configuration:
  drenv_override:
    ENABLE_S3_INGESTION: True
    GOOGLE_STORAGE_KEY_ID: <Access Key>
    GOOGLE_STORAGE_SECRET: <Secret>
 ```

`ENABLE_S3_INGESTION` : Must be set to `True` to enable google storage ingest using S3 interoperability.
`GOOGLE_STORAGE_KEY_ID` : Access Key created in Google Cloud Console.
`GOOGLE_STORAGE_SECRET` : Secret value for the above key.
