# SAML Single Sign-On Integration

DataRobot could use external services (Indentity Providers, IdP) for user authentication through Single Sign-On (SSO) technology. DataRobot supports SSO based on SAML protocol.

## Enable Single Sign-On

Single Sign-On feature is disabled by default. Update your `config.yaml` to enable SSO:

```yaml
---
app_configuration:
    drenv_override:
        ENABLE_SAML_SSO: true
```

## SSO Configuration Permissions

SSO configuration is disabled by default. There is a flag `Enable SAML SSO configuration management` to enable it. `Manage SSO` tab appears under `APP ADMIN` when `Enable SAML SSO configuration management` is checked.

## SSO Configuration

Single Sign-On should be configured on both Identity Provider and DataRobot sides.

### Identity Provider configuration

Identity Providers implement their own dashborads, so customer should reach IdP's documentation to integrate DataRobot. IdP requires from DataRobot sign in and sign out urls. They are represented on the `Manage SSO` page under `Single Sign-On URL` and `Single Sign-Out URL` settings.
DataRobot expects to receive username and email from the identity provider. IdP should be configured so that the SAML response contains `username` attribute (mandatory) and `email` attribute (optional, recommended).

### DataRobot configuration

`Manage SSO` page represents form for SSO configuration. It has following configuration fields:

* `Entity Id` - Unique identifier. Provided by Identity Provider
* `IdP Metadata URL` - link to XML document with integration specific information

There are following settings in advanced configuration:

* `User Session Length (sec)` - Session cookie expiration time. Default is month
* `SP Initiated Method` - SAML metod which is used to start authentication negotiation
* `IdP Initiated Method` - SAML method which is used to move user to DataRobot after successful authentication
* `Identify Provider Metadata` - XML document with integration specific information (for the case IdP doesn't provide `IdP Metadata URL`)

<img src="images/sso-saml-configuration.png" alt="SSO SAML Configuration" style="border: 1px solid black;" width="500" />

### User impersonation

In order to enable user impersonation on environments with SAML SSO please put the following to `config.yaml`:

```yaml
---
app_configuration:
    drenv_override:
        ENABLE_USER_IMPERSONATION: true
```

The username to use for impersonation will be take from attribute `impersonation_user` of SAML response.

## Sign In

After SSO is configured, Single Sign-On button appears on sign in screen. User is redirected to Identity Provider's authentication page after clicking on it.

User is redirected to DataRobot after successful sign on.

## Advanced SSO Configuration

Some advanced configuration options are not exposed in UI and are
available via admin SSO configuration API.

In order to use that API administrator needs to have regular SSO
management permissions and grab API token from own profile in UI
(referred as `<API_TOKEN>` below).

### Encrypted Request

In order to enable authentication request signing please

1. put your encryption certificate and key files into `/opt/datarobot/DataRobot-6.x.x/etc/certs/`,
2. configure the application:

```bash
curl '<DATAROBOT_ENDPOINT>/api/v2/admin/sso/saml/configuration/global/' -X PATCH -H 'Content-Type: application/json;charset=UTF-8' -H 'Authorization: Token <API_TOKEN>' --data-binary '
{
  "advancedConfiguration": {
    "samlClientConfiguration": {
      "service": {"sp": {"authn_requests_signed": true}},
      "key_file" : "/opt/datarobot/etc/certs/key.pem",
      "cert_file" : "/opt/datarobot/etc/certs/cert.pem"
    }
  }
}'
```

### Encrypted Response

If SAML identity provider ecnrypts response assertions, please

1. put your encryption certificate and key files into `/opt/datarobot/DataRobot-6.x.x/etc/certs/`,
2. configure the application to use that certificate:

```bash
curl '<DATAROBOT_ENDPOINT>/api/v2/admin/sso/saml/configuration/global/' -X PATCH -H 'Content-Type: application/json;charset=UTF-8' -H 'Authorization: Token <API_TOKEN>' --data-binary '
{
  "advancedConfiguration": {
    "samlClientConfiguration": {
      "encryption_keypairs" : [{
        "key_file" : "/opt/datarobot/etc/certs/key.pem",
        "cert_file" : "/opt/datarobot/etc/certs/cert.pem"
      }]
    }
  }
}'
```

#### Encrypted Response with Okta

When using encrypted assertions with Okta, please additionally specify `id_attr_name`:

```bash
curl '<DATAROBOT_ENDPOINT>/api/v2/admin/sso/saml/configuration/global/' -X PATCH -H 'Content-Type: application/json;charset=UTF-8' -H 'Authorization: Token <API_TOKEN>' --data-binary '
{
  "advancedConfiguration": {
    "samlClientConfiguration": {
      "encryption_keypairs" : [{
        "key_file" : "/opt/datarobot/etc/certs/key.pem",
        "cert_file" : "/opt/datarobot/etc/certs/cert.pem"
      }],
      "id_attr_name" : "Id"
    }
  }
}'
```
