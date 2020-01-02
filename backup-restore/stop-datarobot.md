<a name="stop-datarobot"></a>
# Stop the DataRobot Application
--------------------------------

In order to ensure that data remains consistent between the various application components, stopping the DataRobot application prior to performing a backup is recommended.

<a name="stopping-services"></a>
## Stop the DataRobot Application Services
------------------------------------------
```bash
bin/datarobot services stop
```

Use this command to stop DataRobot.  You execute this cluster-wide command from the provisioner host, under the same directory as `config.yaml`.  This command stops all of the services on all of the hosts configured in that file.
