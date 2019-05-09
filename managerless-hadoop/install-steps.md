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
WEB_API_LOCATION=http://<app_node_host>/api/v0/
new-queue.RABBITMQ_URL_QUEUE=amqp://datarobot:drrmqpass@<app_node_host>:5672/queue
DATAROBOT_HOME=<path_to_extracted_code>
tempstore.host=<app_node_host>
ZK_QUORUM=<zk_quorum>
CONFIGURATION_API_ENDPOINT=http://<app_node_host>:8027/getconfig
# default value: defaultkey or verify with Hadoop team for encryption_key
CONFIGURATION_API_ENCRYPTION_KEY=defaultkey

# Fields which are usually customized:
DSSMMW_CONTAINER_MEM=30000
LWMMW_CONTAINER_MEM=2048
MASTER_CONTAINER_MEM=4096
MMW_CONTAINER_MEM=30000
MMW_CONTAINER_VCORES=1
PING_CONTAINER_MEM=2048
QUICK_WORKER_CONTAINER_MEM=2000
QUICK_WORKER_CONTAINER_MIN_FREE_MEM_MB=1024
QUICK_WORKER_CONTAINER_NUMBER=0
QUICK_WORKER_CONTAINER_VCORES=2
SCORING_CONTAINER_MEM=2048
SCORING_CONTAINER_VCORES=1
SECURE_WORKER_CONTAINER_MEM=30000
SECURE_WORKER_CONTAINER_VCORES=1

# Do not adjust the following fields unless you are sure you have to
CONFIGURATION_API_POLL_FREQUENCY_IN_SECONDS=10
SO_SCORING_CONTAINER_MEM=4096
SO_SCORING_CONTAINER_VCORES=1
SO_SPARK_CALC_STRATEGY=heuristic
SO_SPARK_CONF_OVERRIDE=
SO_SPARK_DRIVER_CORES=1
SO_SPARK_DRIVER_JAVA_OPTS=
SO_SPARK_DRIVER_MEM=15360
SO_SPARK_EXECUTOR_CORES=1
SO_SPARK_EXECUTOR_JAVA_OPTS=
SO_SPARK_MAX_EXECUTOR_MEM=8192
SO_SPARK_MAX_EXECUTOR_NUM=5
SOM_SPARK_OPTIONS=--master yarn --driver-cores 1 --driver-memory 5g --num-executors 4 --executor-cores 1 --executor-memory 4g --class com.datarobot.so.RunScaleoutJob --driver-class-path "/usr/iop/current/hadoop-yarn-client/lib/*" --conf 'spark.yarn.am.extraJavaOptions="-Diop.version=4.2.0.0"' --conf 'spark.driver.extraJavaOptions="-Diop.version=4.2.0.0"' --jars $DATAROBOT_HOME/lib/datarobot-so.jar --queue $YARN_QUEUE $DATAROBOT_HOME/lib/datarobot-so.jar
ALLOW_SELF_SIGNED_CERTS=False
AM_RACK=
EDA_RACKS=
ENABLE_GRAPHITE_REPORTER=false
ENABLE_JMX_REPORTER=false
ENABLE_LOGGER_REPORTER=false
GPU_RACKS=
GRAPHITE_ADDRESS=
GRAPHITE_PREFIX=
JMX_PORT=55777
MODELING_RACKS=
secure-worker.YARN_SECURE_WORKER_USER_TASK_IMAGE=subprocess
SECURITY_CONTAINER_USE_DELEGATION_TOKENS=true
tempstore.port=6379
YARN_CPU_SCHEDULING=false
yarn_queue=default

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
export CONTAINER_CONFIG_FILE=/home/datarobot/datarobot-master.conf
export CONFIGURATION_API_ENDPOINT=http://<app_node_host>:8027/getconfig
# default value: defaultkey or verify with Hadoop team for encryption_key
export CONFIGURATION_API_ENCRYPTION_KEY=defaultkey
export CONFIGURATION_API_POLL_FREQUENCY_IN_SECONDS=10
```

Please use `screen` (or any similar tool) to run `datarobot.sh` in the background,
passing required parameters as follows:
```bash
./datarobot.sh start_master $LICENSE_KEY $DATAROBOT_PROVISIONING_HOST datarobot
```

This will start the application master and restart services on the
application node.
