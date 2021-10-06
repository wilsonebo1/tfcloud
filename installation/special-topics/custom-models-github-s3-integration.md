# Custom Models GitHub and S3 integration

Custom Models is a feature that allows user to deploy arbitrary user models into the DataRobot.
The Custom Models GitHub and S3 integration provides a convenient way to upload model sources from remote repositories.

The GitHub integration is done via the GitHub application, see https://docs.github.com/en/developers/apps/about-apps.


## GitHub Configuration

Configuration to support GitHub happens in two locations, in the customer's GitHub account and then in DataRobot.

### Register a new application

Go to https://github.com/settings/apps/new and register a new GitHub application using the configurations from the table below:

| Property | Value |
|:-----------|:-----|
| Name | Enter arbitrary name. Name must be unique, up to 34 characters |
| Homepage URL | https://datarobot.com |
| User authorization callback URL <br><br><br> | `http://[APP SERVER FQDN OR IP]/account/github/authz_return`  <br><br> **Note:** use the "HTTPS" protocol only if it is enforced in the current DataRobot installation |
| Expire user authorization tokens <br><br><br>| OFF <br><br> **Note:** it's the new GitHub's Beta feature and is not yet supported by DataRobot |
| Request user authorization (OAuth) during installation | ON |
| Redirect on update | ON |
| Webhook - “Active”` | OFF |
| Repository Permissions | Set to "Read-Only": 1) Contents and 2) Metadata |
| Where can this GitHub App be installed | Any account |

Press "Create GitHub App" and copy following properties from the next page:
* `Client ID`
* `Client secret`
* `Public Link` - copy only an `application name slug` part of a URL. For example:

| Public link | Application name slug |
|:-----------|:-----|
| https://github.com/apps/datarobot-user-models-test | datarobot-user-models-test |
<br>

**IMPORTANT:**
Application ownership must be transferred to a user/organization responsible for managing access to organization's GitHub repositories. 
Read the documentation: https://docs.github.com/en/developers/apps/transferring-ownership-of-a-github-app
<br><br><br><br><br>


### DataRobot settings

* Update `config.yaml`:

```yaml
---
os_configuration:
    CUSTOM_MODEL_GITHUB_OAUTH_CLIENT_ID: <Client ID>
    CUSTOM_MODEL_GITHUB_OAUTH_CLIENT_SECRET: <Client secret>
    SECRETS_ENFORCED: true

app_configuration:
    drenv_override:
        CUSTOM_MODEL_GITHUB_APP_NAME: <Application name slug>
        ENABLE_CREDENTIAL_STORAGE_FOR_ALL_USERS: true
```

* Execute `./bin/datarobot reconfigure`


## S3 configuration

If you did the "GitHub Configuration" steps, the S3 integration will be already available. To enable only S3 integration, do following:   

* Update `config.yaml`:

```yaml
---
app_configuration:
    drenv_override:
        ENABLE_CREDENTIAL_STORAGE_FOR_ALL_USERS: true
```
* Execute `./bin/datarobot reconfigure`
