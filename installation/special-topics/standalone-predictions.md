# Standalone Predictions

When a Dedicated Prediction Engine is Licensed from DataRobot an alternate configuration of the Dedicated prediction engine (DPE) is the Standalone Scoring Engine (SSE) which is used for generating predictions independently from the rest of DataRobot services.
SSE clusters run only the services required to run prediction API servers using an imported `*.drx` model file, namely `scoringengine` and `dedicatedpredictionnginx`, plus an optional `minio` service for distributed storage.

Sections below explain how to perform an installation of DataRobot with just standalone scoring services.

## Configuration

Every server in the SSE-only DataRobot installation needs to run `scoringengine` and `dedicatedpredictionnginx` services.
One of the nodes in the cluster needs to also run a `provisioner` for the installation to work.
Optionally, distributed storage service such as `minio` can be added to one of the nodes, if needed.

Note that DataRobot installation script requires you to provide `webserver_hostname` in `os_configuration` even if the cluster doesn't have a `webserver`.
In order to workaround this limitation any non-empty valid hostname string can be used as a value. For example:

```yaml
---
# config.yaml snippet
os_configuration:
  webserver_hostname: localhost
```

### Examples

Example `servers` section in the configuration for a single box cluster not running distributed storage:

```yaml
# config.yaml snippet
---
servers:
- app_configuration:
    dedicated_prediction_server: true
    drenv_override:
      FILE_STORAGE_TYPE: local
  hosts:
  - 192.168.1.1
  services:
  - provisioner
  - scoringengine
  - dedicatedpredictionnginx
```

**Note:** For SSE clusters with `FILE_STORAGE_TYPE: local`, model import needs to be performed for every node in the cluster, since local file system of each server will be used for storing the `*.drx` file. This is not the case for clusters configured to use distributed storage such as `minio` -- model import needs to happen once on any node in the cluster in order for it to be accessible for generating predictions.

Example `servers` section in the configuration for a single box cluster running MinIO for storage:

```yaml
# config.yaml snippet
---
servers:
- app_configuration:
    dedicated_prediction_server: true
    drenv_override:
      FILE_STORAGE_TYPE: s3
  hosts:
  - 192.168.1.1
  services:
  - provisioner
  - minio
  - scoringengine
  - dedicatedpredictionnginx
```
