# Data ingestion from Google Cloud Storage

It is possible to ingest files into DataRobot directly from Google Cloud Storage objects using links as `gs://<bucket-name>/<file-name.csv>`. The implementation relies on Google Cloud Storage implementation of AWS S3 protocol, also known as Interoperability feature.

## Required Google Cloud configuration

The Interoperability feature is disabled by default. You must enable this feature as well as create an Access Key and Secret Key in the Google Cloud Console under the `Storage > Settings > Interoperability`.

## DataRobot application configuration

Once you create an Access Key and Secret Key you can store these key references in the following environmental variables:

`GOOGLE_STORAGE_KEY_ID`: Access Key created in Google Cloud Console.  
`GOOGLE_STORAGE_SECRET`: Secret Key value for the above key.

Note: This feature works on top of S3 protocol and requires the configuration option `ENABLE_S3_INGESTION` to be set to `True`.
