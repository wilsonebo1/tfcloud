# AI App Builder

App Builder allows users to create AI Apps that can make predictions, scenario optimization and comparison in the No Code environment. In addition, there are visualization capabilities that will allow users to create insights for their predictions. This feature is available as Public Beta starting from 7.1 release.

## Configuration

There are several services that need to be deployed: `appsbuilderapi`, `appsinternalapi` and `appsbuilderworker`. App Builder also depends on our auth server which needs additional service - `authserver`.

Make sure that they are listed in your `config.yaml` under the `services` section.

Also, you need to provide other configuration options to set-up auth-server.

Example:

```
webserver_hostname: { external-facing, will be used for applications redirect also }

# Global drenv_override
ENABLE_APPSBUILDER_SERVICE: true
ENABLE_APPLICATIONS_FOR_ALL_USERS: true

services:
  - authserver
  - appsbuilderapi
  - appsinternalapi
  - appsbuilderworker

hosts:
  - { internal host/IP address }

app_configuration:
  drenv_override:
    EXTERNAL_WEB_SERVER_URL: { public URL, will be used for applications redirect also }
    EXTERNAL_WEB_SERVER_URL_FORCED: false
    OAUTH2_CLUSTER_ENABLED: true
```

## Usage

Users also need to have feature flag enabled in order to be able to access "Applications" view and create apps - "Enable Application Builder Service" (`ENABLE_APPSBUILDER_SERVICE`);
