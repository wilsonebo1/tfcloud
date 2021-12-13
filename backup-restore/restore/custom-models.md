# Restoring Custom Models

DataRobot Custom Models are executed on a Kubernetes cluster. Every custom model is backed by DataRobot filestore and Mongo data.
This means thats:
* A backup of all custom models is represented by a backed up state of DataRobot filestore and Mongo.
* Restoring Custom Models to a running state is fully possible using this data.

In order to recover all custom models data into a running state on a target installation where the restore is happening, DataRobot provides an additional Python script that should be called after:
* Filestore and Mongo have been restored
* Application is in a running state.
* Installation Admin API token is available, required for the script execution.


```bash
/opt/datarobot-runtime/app/DataRobot/tools/custom_model/restore_custom_models.py --admin-api-token <ADMIN_API_TOKEN> --webserver-address https://dr.myserver.com
```

A similar output will be presened where each eligible custom model will be restored and reenabled one by one.

```
2021-11-16 00:40:24 INFO     Custom Model LRS list to start (1): ['6192d2abdb1a2688cb94b968']
2021-11-16 00:40:24 INFO     Starting Custom Model LRS 6192d2abdb1a2688cb94b968
2021-11-16 00:40:35 INFO     Started Custom Model LRS 6192d2abdb1a2688cb94b968
2021-11-16 00:40:35 INFO     Started: 1 models. Failed: 0 models
```

The script is idempotent and will not alter custom models that were already running at the time of execution.
