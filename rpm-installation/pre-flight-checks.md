# Pre-Flight Checks

## Manual Health Checks

Perform these steps after performing the [Cluster Preparation](standard-install.md#linux-prep) section of the installation (after `./bin/datarobot setup-dependencies`) and before performing the [Install and Configure the Application](standard-install.md#linux-provision) steps (before `./bin/datarobot install`).

## Provisioner connectivity

On the install node, logged in as the DataRobot user, run the following to verify the provisioner will be able to connect to all nodes in the cluster:

```bash
sudo su dradmin
cd /opt/datarobot/DataRobot-4.2.x/
source release/profile
./bin/inventory --list
./bin/ansible -i ./bin/inventory -m shell -a 'uptime' all
```

# Hadoop Pre-Flight Checks {#hadoop-checks}

Use these checks before installation to ensure that your Hadoop environment is ready to install and run DataRobot.


## Service health and configuration

Check for health and configuration issues reported by Hadoop Manager.

**CDH**:

<img src="images/cdh-health-check.png" alt="" style="border: 1px solid black;"/>

## Test YARN Container Submission

Ensure the datarobot user can submit yarn applications with the required container size.
Modify the `container_memory`, `num_containers` and `container_vcores` parameters to match your expected container size.

**CDH**:

```bash
yarn jar \
    /opt/cloudera/parcels/CDH/lib/hadoop-yarn/hadoop-yarn-applications-distributedshell.jar \
    -shell_command "hdfs dfs -ls /tmp" \
    -debug -appname "DataRobot pre-flight check" \
    -num_containers 3 -container_memory 60000 -container_vcores 4 \
    -jar /opt/cloudera/parcels/CDH/lib/hadoop-yarn/hadoop-yarn-applications-distributedshell.jar
```

At the end you should see a message like `17/10/16 14:38:22 INFO distributedshell.Client: Application completed successfully`.
To check the logs from this job, find the applicationId in the job output, eg. `Submitted application application_1508158073679_0004` and run `yarn logs -applicationId application_1508158073679_0004 | less`.
You should see the content of the `/tmp` directory in `HDFS` in the container stdout logs:

```
LogType:stdout
Log Upload Time:Mon Oct 16 14:38:22 +0000 2017
LogLength:537
Log Contents:
Found 3 items
drwx--x--x   - hbase     supergroup          0 2017-10-16 11:41 /tmp/hbase-staging
drwx-wx-wx   - hive      supergroup          0 2017-10-16 11:43 /tmp/hive
drwxrwxrwt   - mapred    hadoop              0 2017-10-16 11:42 /tmp/logs
```

## Check LDAP Impersonation

In environments with LDAP or user impersonation, ensure the `datarobot` user can successfully impersonate Unix users:

```bash
WEBHDFS_HOST=webhdfs.internal.com
WEBHDFS_PORT=50070
PATH=/tmp/
USER=someusername
curl -i --negotiate -u : "http://${WEBHDFS_HOST}:${WEBHDFS_PORT}/webhdfs/v1/${PATH}?doas=${USER}&op=LISTSTATUS"
```

The HTTP status code should be 200 and the request should return a json object with a list of files:

```bash
HTTP/1.1 200 OK
Cache-Control: no-cache
Expires: Tue, 17 Oct 2017 11:05:27 GMT
Date: Tue, 17 Oct 2017 11:05:27 GMT
Pragma: no-cache
Expires: Tue, 17 Oct 2017 11:05:27 GMT
Date: Tue, 17 Oct 2017 11:05:27 GMT
Pragma: no-cache
Content-Type: application/json
X-FRAME-OPTIONS: SAMEORIGIN
WWW-Authenticate: Negotiate YGYG
Set-Cookie: hadoop.auth="u=USER&p=USER/HOST@REALM&t=kerberos&e=1508274327891&s=PJecazm2pr1wMVKdRfcbTzyI7Gk="; Path=/; HttpOnly
Transfer-Encoding: chunked

{"FileStatuses":{"FileStatus":[
{"accessTime":0,"blockSize":0,"childrenNum":0,"fileId":16403,"group":"supergroup","length":0,"modificationTime":1508238307613,"owner":"hdfs","pathSuffix":".cloudera_health_monitoring_canary_files","permission":"777","replication":0,"storagePolicy":0,"type":"DIRECTORY"},
```

## Check Spark Health

Make sure Spark is installed and functioning:

**CDH**:

```bash
spark-submit --master yarn \
    --num-executors 3 --executor-memory 20g --executor-cores 4 \
    --proxy-user PROXY_USER \
    --class org.apache.spark.examples.SparkPi \
    /opt/cloudera/parcels/CDH/lib/spark/lib/spark-examples.jar 10000
```

When the job finishes you should see the result `Pi is roughly 3.1416745671416746`.
If the installed version of Spark is below 2.0, you will need to create the home directory on HDFS for `PROXY_USER`.
For Spark versions above 2.0, add the parameter `--conf "spark.yarn.stagingDir=<STAGING_DIR_ON_HDFS>"` to your command.
