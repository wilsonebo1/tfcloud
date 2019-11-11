# Data ingestion from Google Cloud Storage

On Premise installations of DataRobot support ingestion of Google Cloud Storage objects using either of two methods described below.

Once configured correctly Google Cloud Storage objects are accessible using links as `gs://<bucket-name>/<file-name.csv>`. 

## Implemenation Option One
Option one for Google Cloud Storage uses native google access and Google IAM roles for access security.

### Required Google Cloud Configuration
In order to use this method, security must be configured to correctly provide access to the bucket and objects.  

First setup a user account in the Google Cloud Console and provide that account access to the storage bucket with Storage Legacy Bucker Reader Role.

Once done there are two options for connecting the account to DataRobot.  

If you are using DataRobot from inside the Google Cloud, configure the DataRobot Instances to use the account as the service account.  DataRobot will automatically detect this and handle authentication.

If the DataRobot are outside of the Google Cloud or you wish to specify the account used to connect, obtain an authentication keyfile from the Google Cloud and upload it to the server running DataRobot.

### DataRobot application configuration
If you are using the service account method for access management, the application credentials is not necessary.  If a keyfile is used, set the following environmental variables:

`GOOGLE_STORAGE_APPLICATION_CREDENTIALS`: Full path to the keyfile (i.e. /home/user/Downloads/[FILE_NAME].json)

`GOOGLE_PROJECT_NAME`: Name of the project from Google Cloud Console

`ENABLE_GS_INGESTION`: Must be set to `True`

## Implementation Option Two
Option two for Google Cloud Storage relies on Google Cloud Storage implementation of AWS S3 protocol, also known as Interoperability feature.

### Required Google Cloud configuration

The Interoperability feature is disabled by default. You must enable this feature as well as create an Access Key and Secret Key in the Google Cloud Console under the `Storage > Settings > Interoperability`.

### DataRobot application configuration

Once you create an Access Key and Secret Key you can store these key references in the following environmental variables:

`GOOGLE_STORAGE_KEY_ID`: Access Key created in Google Cloud Console.  
`GOOGLE_STORAGE_SECRET`: Secret Key value for the above key.

Note: For option two, it works on top of S3 protocol and requires the configuration option `ENABLE_S3_INGESTION` to be set to `True`.
