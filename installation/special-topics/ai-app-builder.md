# AI App Builder

App Builder allows users to create AI Apps that can make predictions, scenario optimization and comparison in the No Code environment. In addition, there are visualization capabilities that will allow users to create insights for their predictions. This feature is available as Public Beta starting from 7.1 release, and GA for 7.2.

## Configuration

There are several services that need to be deployed: `appsbuilderapi`, `appsinternalapi` and `appsbuilderworker`. App Builder also depends on our auth server which needs additional service - `authserver`.

Make sure that they are listed in your `config.yaml` under the `services` section.

Also, you need to provide other configuration options to set-up auth-server.

Example:

```
webserver_hostname: appdatarobot.customer.com  # external-facing, will be used for applications redirect also

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
    EXTERNAL_WEB_SERVER_URL: https://appdatarobot.customer.com  # public URL, will be used for applications redirect also
    EXTERNAL_WEB_SERVER_URL_FORCED: true
    OAUTH2_CLUSTER_ENABLED: true
```

Please note that it's **required** to set `EXTERNAL_WEB_SERVER_URL_FORCED: true` in any of the following scenarios for on-premise installations:
 * FQDNs set in `webserver_hostname` and `EXTERNAL_WEB_SERVER_URL` are different;
 * There is an HTTP -> HTTPS permanent redirect setup on the webserver front proxy / load balancer (at `EXTERNAL_WEB_SERVER_URL`), but `os_configuration['ssl']` is set to `false`.

Otherwise, users might get authentication errors when logging in AI Apps.

## Sizing requirements
The App Builder can be deployed either on a single or multi-node setup. 

| Service |  Memory per service | Notes |
|----------------|:---------------------:|:------------------------:|
| appsbuilderapi | 4 GB |  1x |
| appsinternalapi | 4 GB |  1x |
| appsbuilderworker | 512MB | 1x or more |

The node should have at least 4 core CPU, and additional 8GB of storage for applications data.

## Usage

For 7.1 version users also need to have feature flag enabled in order to be able to access "Applications" view and create apps - "Enable Application Builder Service" (`ENABLE_APPSBUILDER_SERVICE`);
