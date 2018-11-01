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

### DataRobot configuration

`Manage SSO` page represents form for SSO configuration. It has following configuration fields:

* `Entity Id` - Unique identifier. Provided by Identity Provider
* `IdP Metadata URL` - link to XML document with integration specific information

There are following settings in advanced configuration:

* `User Session Length (sec)` - Session cookie expiration time. Default is month
* `SP Initiated Method` - SAML metod which is used to start authentication negotiation
* `IdP Initiated Method` - SAML method which is used to move user to DataRobot after successfull authentication
* `Identify Provider Metadata` - XML document with integration specific information (for the case IdP doesn't provide `IdP Metadata URL`)

<img src="images/sso-saml-configuration.png" alt="SSO SAML Configuration" style="border: 1px solid black;" width="500" />

## Sign In

After SSO is configured, Single Sign-On button appears on sign in screen. User is redirected to Identity Provider's authentication page after clicking on it.

User is redirected to DataRobot after successfull sign on.
