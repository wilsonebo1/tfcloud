# BigQuery

DataRobot supports using Google's BigQuery as an ingestion source for data.
This is done via OAuth. DataRobot will open an OAuth request to Google and the user will then click on a button to allow (or disallow) DataRobot access to their BigQuery.


## Configuration

Configuration to support BigQuery happens in two locations, in the customer's Google Console and then in DataRobot.

### Google API Credentials

In the Google Cloud Console, create API credentials for web application, with `https://<your-DR-cluster>/account/google/bigquery_authz_return` in authorized redirect URIs

### Google OAuth application

In the Google Cloud Console, an OAuth application must be created. To support BigQuery ingestion, the following scopes must be added to the OAuth application:

- https://www.googleapis.com/auth/devstorage.read_write
- https://www.googleapis.com/auth/bigquery.readonly

After setting this, download the OAuth application credentials/settings. This json file will contain the `client_id` and `client_secret` that are needed in the DataRobot settings below.

### DataRobot settings
You must use HTTPS SSL and a valid DNS name for your DataRobot cluster webserver, or at least have the server name in your local hosts  file.

#### Build a single jar file

DataRobot interacts with BigQuery via JDBC. Google provides a JDBC Driver for BigQuery and it can be found here: https://cloud.google.com/bigquery/providers/simba-drivers/

Once that Zip File is Downloaded, you’ll find that includes 57 jars that are all required for proper functionality.

To simplify DataRobot setup, we can repackage them into a single jar file. An example of this:

``` bash
mkdir BigQuery
cd BigQuery
curl -o SimbaJDBCDriverforGoogleBigQuery42_1.2.0.1000.zip https://storage.googleapis.com/simba-bq-release/jdbc/SimbaJDBCDriverforGoogleBigQuery42_1.2.0.1000.zip
unzip SimbaJDBCDriverforGoogleBigQuery42_1.2.0.1000.zip
mkdir uberJar
cd uberJar/
for jar in `ls ../*.jar`; do jar xf $jar; done
jar cf DataRobotBigQuery.jar .
```

This produces one large jar file, which can then be easily added DataRobot in the JDBC Drivers section.


#### Secrets Configuration

In the config.yaml setting the following env vars should allow DataRobot to pickup the customer’s Google credentials and allow an on-prem installation to use the OAuth settings. Using the credentials from the Google OAuth application, update `secrets.yaml`:

```yaml
---
google_auth_client_id: "client-id-string-from-google-configuration.apps.googleusercontent.com"
google_auth_client_secret: "client-secret-string-from-google-configuration"
```

#### Additional steps

If BigQuery or user credential storage is not enabled in DataRobot:

* Update `config.yaml`:

```yaml
---
servers:
- app_configuration:
    drenv_override:
        BIGQUERY_ENABLED: true
        ENABLE_CREDENTIAL_STORAGE_FOR_ALL_USERS: true
```

* Execute `./bin/datarobot reconfigure`
