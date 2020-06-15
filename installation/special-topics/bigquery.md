# BigQuery

DataRobot supports using Google's BigQuery as an ingestion source for data.
This is done via OAuth. DataRobot will open an OAuth request to Google and the user will then click on a button to allow (or disallow) DataRobot access to their BigQuery.


## Configuration

Configuration to support BigQuery happens in two locations, in the customer's Google Console and then in DataRobot.

### Google OAuth application

In the Google Cloud Console, an OAuth application must be created. To support BigQuery, a scope must be added to the OAuth application:

- https://www.googleapis.com/auth/bigquery

After setting this, download the OAuth application credentials/settings. This json file will contain the `client_id` and `client_secret` that are needed in the DataRobot settings below.

### DataRobot settings


In the config.yaml setting the following env vars should allow DataRobot to pickup the customer’s Google credentials and allow an on-prem installation to use the OAuth settings.

Using the credentials from the Google OAuth application, update `secrets.yaml`:

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
