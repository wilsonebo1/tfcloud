## Steps to start the application master

### On the application node
1. Remove `datarobot-defaults.conf` if it exists
2. Add to `config.yaml` the parameter `HADOOP_CONFIG_SHARE: true`
3. Reconfigure the cluster using `./bin/datarobot reconfigure`

### On the DataRobot Master node (Hadoop)

Create the `datarobot-master.conf` file.
This file should contain all the required configuration for DataRobot's YARN application
master:

```properties
# Fields which must be customized:
CONFIGURATION_API_ENDPOINT=http://<app_node_host>/hadoopconfig/getconfig
# default value: defaultkey or verify with Hadoop team for encryption_key
CONFIGURATION_API_ENCRYPTION_KEY=defaultkey
CONFIGURATION_API_POLL_FREQUENCY_IN_SECONDS=10
```

Copy `datarobot.sh` to the working directory and make it executable.

Export environment variables to launch datarobot.sh:
```bash
export ZK_QUORUM=<zk_quorum>
export DATAROBOT_PROVISIONING_HOST=<app_node_host>
export LICENSE_KEY=<dr_license>
export DATAROBOT_DIRNAME=<parcel_name>
export PARCEL_PATH=<path_to_the_parcel>
export DATAROBOT_HOME=$PARCEL_PATH
export DATAROBOT_PATH=$PARCEL_PATH/bin:$PARCEL_PATH/lib/maven/bin:$PARCEL_PATH/cuda/bin:$PATH
export DATAROBOT_PYTHONHOME=$PARCEL_PATH
export DATAROBOT_PYTHONPATH=$PARCEL_PATH/lib/DataRobot:$PYTHONPATH
export DATAROBOT_LD_LIBRARY_PATH=$PARCEL_PATH/lib/:$PARCEL_PATH/cuda/lib64:$PARCEL_PATH/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
export DATAROBOT_R_HOME=$PARCEL_PATH/lib/R
export NLTK_DATA=$DATAROBOT_HOME/share/nltk_data
export MECAB_CONFIG_LOCATION=$DATAROBOT_HOME/bin/mecab-config
export DATAROBOT_PRINCIPAL=<principal_name>
export KERBEROS_PRINCIPAL=$DATAROBOT_PRINCIPAL
export DATAROBOT_CUSTOM_KEYTAB_PRINCIPAL=$DATAROBOT_PRINCIPAL
export DATAROBOT_CUSTOM_KEYTAB_FILE=/home/datarobot/datarobot.keytab
export HADOOP_CONF_DIR=/etc/hadoop/conf.empty/
export HADOOP_CONFIG_ENCRYPTION_KEY=defaultkey
```

Please use `screen` (or any similar tool) to run `datarobot.sh` in the background,
passing required parameters as follows:
```bash
./datarobot.sh start_master $LICENSE_KEY $DATAROBOT_PROVISIONING_HOST datarobot
```

This will start the application master and restart services on the
application node.
