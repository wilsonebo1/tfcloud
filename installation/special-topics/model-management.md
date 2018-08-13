# Model Management

In order to be able to "deploy" DataRobot models to dedicated prediction servers and use
advanced model monitoring features like tracking of target or feature drift one must configure
dedicated prediction servers in the following way:

```yaml
# dedicated high-performance prediction servers
- services:
  - dedicatedpredictionapi
  - dedicatedpredictionnginx
  - modmonrsyslogslave
  hosts:
  - x.x.x.x
  - y.y.y.y
  app_configuration:
    # recommended configuration for dedicated prediction server
    dedicated_prediction_server: True
    drenv_override:
      WORKER_MODEL_CACHE: 16 # Models to cache in memory at once. Tune this for your use case
      MODEL_CACHE_MODE: LRU # Mode for caching models. Options: LRU, latest
      # enable model management features
      PREDICTION_API_MONITOR_USAGE_ENABLED: true   # service stats
      PREDICTION_API_MONITOR_RESULT_ENABLED: true  # target drift
      PREDICTION_API_MONITOR_RAW_ENABLED: true     # feature drift
```

Note that in addition to an example configuration in `multi-node.linux.yaml` we now run one
additional service on dedicated prediction API nodes - `modmonrsyslogslave`.

One more server is needed for model management data collection and processing:

```yaml
- services:
  - pgsql
  - modmonrsyslogmaster
  - modmonworker
  hosts:
  - z.z.z.z
```

Note, that this server will run an instance of TimescaleDB RDBMS. The recommended hardware
configuration is 16 Gb of RAM (or more) and 4 CPU cores (or more). It's possible to colocate
these services with the services running on the `webserver` node, but one needs to make sure this
node has enough CPU/memory resources.
