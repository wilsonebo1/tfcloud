<a name="start-datarobot"></a>
# Start the DataRobot Application
----------------------------------

Use this command to start the DataRobot Docker Registry.  You execute this command from the provisioner host, under the same directory as `config.yaml`:

<a name="starting-registry"></a>
## Start the Docker Registry for Docker-based DataRobot Installations
---------------------------------------------------------------------
```bash
bin/datarobot run-registry
```

Use this command to start DataRobot.  You execute this cluster-wide command from the provisioner host, under the same directory as `config.yaml`.  This command starts all of the services on all of the hosts configured in that file.  This command works for both Docker and RPM-based DataRobot installations:

<a name="starting-services"></a>
## Start the DataRobot Application Services
-------------------------------------------
```bash
bin/datarobot services start
```

After restoring DataRobot you must reconfigure the application to make sure that all IPs and configurations have been updated on the application hosts and containers.  If you fail to run this step it is likely that you will not see previous projects, models, or AI Catalog documents.  Use the following command on the provisioner host to reconfigure DataRobot cluster-wide:

<a name="reconfigure-datarobot"></a>
## Reconfigure DataRobot
------------------------
```bash
bin/datarobot reconfigure
```
