# Model Management

## Dedicated Prediction Servers

In order to be able to "deploy" DataRobot models to dedicated prediction servers and use
advanced model monitoring features like tracking of target or feature drift one must configure
dedicated prediction servers in the following way:

```yaml
# dedicated high-performance prediction servers
- services:
  - dedicatedpredictionapi
  - dedicatedpredictionnginx
  - modmonrsyslogmaster
  hosts:
  - x.x.x.x
  - y.y.y.y
  app_configuration:
    # recommended configuration for dedicated prediction server
    dedicated_prediction_server: True
    drenv_override:
      WORKER_MODEL_CACHE: 16 # Models to cache in memory at once. Tune this for your use case
      MODEL_CACHE_MODE: LRU # Mode for caching models. Options: LRU, latest
```

## Deployment Monitoring

Deployment monitoring functionality (e.g. service health, drift tracking, accuracy tracking, etc.) requires a few
additions to the example configuration in `multi-node.yaml`. Specifically, we run one
additional service on dedicated prediction API nodes - `modmonrsyslogmaster`.

One more server is needed for model management data collection and processing:

```yaml
- services:
  - pgsql
  - modmonscheduler
  - modmonworker
  hosts:
  - z.z.z.z
```

Note that this server will run an instance of PostgreSQL with the TimescaleDB extension. The recommended hardware
configuration is 16 Gb of RAM (or more) and 4 CPU cores (or more). It's possible to colocate
these services with the services running on the `webserver` node, but one needs to make sure this
node has enough CPU/memory resources.

### Deployments Without Monitoring

Note that as of version 5.3, we now enable basic Deployment functionality even when the additional hardware/services
required for Deployment Monitoring are absent.

metarobot will automatically detect the presence/absence of these services and will set environment variables
appropriately (which in turn, enables/disables features), but you can also set these environment variables manually if desired.
To guarantee that you can use deployments, but with monitoring disabled, add the following to the *Global environment block*:
      
```bash
app_configuration:
  drenv_override:
    ENABLE_MODEL_DEPLOYMENTS=true  # (Optional, defaults to true in app)
    DISABLE_MMM_MONITORING=true
```

### Going From Monitoring Disabled to Enabled

As of version 5.3, deployments can be made even when monitoring is disabled and its prerequisite services are absent.
In this case, we message to users that they are missing out on monitoring functionality and that if they want it,
their system admin must install the required services and contact support to enable monitoring. There are some nuances
in this process worth knowing about.

Steps to Enable Monitoring:
1) Add the services mentioned in the [Deployment Monitoring](#deployment-monitoring) section above. 
2) Verify that all PGSQL and RSYSLOG environment variables were set as expected. Additionally, these environment
   should be set correctly in the *Global environment block*:
      ```bash
      app_configuration:
        drenv_override:
          ENABLE_MODEL_DEPLOYMENTS=true  # (Optional, defaults to true in app)
          DISABLE_MMM_MONITORING=true
      ```
3) Perform a full app restart. This will ensure that the new services are started and already-running services pick up
   environment variable changes.

Nuances:
- Deployments that were made before the migration _will_ continue to work post-migration.
- Prediction and service health statistics _will_ work retroactively for all deployments automatically.
- Following the above process, users must manually turn on Drift Tracking via UI or API for each Deployment that they
  want target/feature drift and accuracy tracking for.
- Once Drift Tracking has been enabled for a given Deployment, target drift will automatically populate for predictions
  made retroactively. However, feature drift and accuracy tracking will only appear for new predictions made going
  forward.