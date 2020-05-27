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
  - predictionspooler
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

Deployment monitoring functionality (e.g. service health, drift tracking, accuracy tracking, etc.) requires a few
additions to the example configuration in `multi-node.yaml`. Specifically, we run two more
additional services on dedicated prediction API nodes - `modmonrsyslogmaster` and `predictionspooler`.

The `predictionspooler` service was introduced in DataRobot 6.1. It is optional but highly
recommended, since `dedicatedpredictionapi` service is in a compatibility mode and automatically takes over
the function of `predictionspooler` if the latter is not available.
This compatibility mode might be removed in future versions.


Note: Model Management and Monitoring capabilities are not available for old pid/lid - based (project/model ID) prediction API routes.
Only model deployments ("deployed" models) support the monitoring.


## Model Monitoring Server

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
      
```yaml
app_configuration:
  drenv_override:
    ENABLE_MODEL_DEPLOYMENTS: true  # (Optional, defaults to true in app)
    DISABLE_MMM_MONITORING: true
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
  ```yaml
  app_configuration:
    drenv_override:
      ENABLE_MODEL_DEPLOYMENTS: true  # (Optional, defaults to true in app)
      DISABLE_MMM_MONITORING: true
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
  
  
### Extended Drift Tracking

6.1 release introduces several improvements to Model Monitoring, called "Extended Drift Tracking", enabled by default.
Improvements include the following:
* Tracking up to 25 features (limit raised from 10 in previous DataRobot versions).
This applies to existing deployments after a successful model replacement and to all new deployments.
* Tracking text features.
* Removing the previously recommended limit of 5MB for the size of prediction requests that are eligible
to be tracked by Model Monitoring.

The monitoring backend has been reworked in order to support the listed improvements.
The old backend is still available and can be easily switched to with a single configuration option. Example of a configuration
that completely switches the cluster back to the old backend:

```yaml
app_configuration:
  drenv_override:
    DISABLE_MMM_PREDICTIONS_EXTENDED_DRIFT: true
```

### Fine-tuning

Analytics for deployment monitoring is periodically processed by background jobs, thus they might not become available
immediately after predictions are made. By default prediction requests made might take up to 30 seconds to impact
the Data Drift / Accuracy results of a particular deployment.
A more frequent processing makes statistics available quicker, but comes with a price of a higher I/O and less efficient
processing. Example of a customization:

```yaml
app_configuration:
  drenv_override:
    MMM_PREDICTIONS_DATA_FLUSH_INTERVAL_SECONDS: 10
```

The centerpiece of the monitoring system is `modmonworker` service. It makes use of DataRobot models metadata and feature
information for analytical purposes. For better performance it utilizes a model cache.
The default cache size is 4.
A bigger cache size will allow the service to retain more models in memory and increase the throughput of the `modmonworker`, however
this may increase the memory footprint of the `modmonworker`.
In most cases due to the async / delayed nature of the work this service is performing, increasing the cache size should be considered
only if an intense high-load system with many various models is desired.
In general memory required to load one model is a fraction of an estimate of the model file size, unless it's an import .mlpkg file
(Model file size is available under the Describe -> Model Info section of a leaderboard model).
Model package files are fully loaded and their size can be used as an approximate estimate.

```yaml
app_configuration:
  drenv_override:
    # Increased size of the Monitoring model cache size from 4 up to 10.
    MMM_PREDICTIONS_DATA_MODEL_LOADER_CACHE_SIZE: 10
```

Downscaling in order to never keep more than one model can be done by setting the cache size to 1.

### Prediction Row Storage

DataRobot 6.1 introduces a concept called prediction row storage. DataRobot can store prediction request data at the row level
for deployments. This involves prediction scoring data and prediction results. Storing prediction request rows enables
an organization to request a thorough audit of the predictions they made and use that data to troubleshoot operational issues.
For instance, examining the data to understand an anomalous prediction result.

Please contact support@datarobot.com to discuss prediction auditing needs or in order to troubleshoot previously made predictions for the
deployments with enabled prediction row storage.

To enable the collection of prediction request rows, navigate to the Data Drift Settings modal for a deployment
from the Actions menu or during deployment creation by enabling the "Enable prediction rows storage" toggle.
Note that during deployment creation this toggle appears under the Inference Data section.

Once toggled on, prediction requests made for that deployment are collected by DataRobot.
Note that requests are collected if the scoring data is of a valid data format, that can be interpreted by DataRobot, i.e. a valid CSV/json.
Requests with a valid data format that don't satisfy all the input feature requirements of an underlying deployed model, are still eligible.

Data is stored in DataRobot's backend storage.
Disk space requirements: Expect the stored prediction data to take up to 20-100% of the size of prediction requests made.
For example you are making predictions against a deployment every second using a 10kb CSV file.
This means a 10kb * 60 * 60 * 24 = 884MB of prediction requests daily. It would be recommended to have as much free disk space
for each day of collecting data. Due to compression, much less storage may be required.

The following configuration will disable data collection for the entire DataRobot cluster and will prevent prediction pow storage from being enabled on any deployment

```yaml
app_configuration:
  drenv_override:
    DISABLE_MMM_PREDICTIONS_DATA_COLLECTION: true
```

Data is not removed automatically. Removal of deployment data can be performed as a part of a deployment perma-deletion, available via
an API endpoint `/api/v2/deletedDeployments/`. Using this endpoint requires a CAN_DELETE_APP_PROJECTS user permisision. Visit the API reference for more details.
