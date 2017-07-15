# Upgrading DataRobot
Use the following instructions to prepare your DataRobot cluster for upgrade.

## Remove old files and services
* On each node, stop and remove all containers.
```bash
    docker rm $(docker stop $(docker ps -aq))
```
* Remove the DataRobot code directory:
```bash
    rm -rf /opt/datarobot/DataRobot/
```
* Stop the Docker daemon
```bash
    systemctl stop docker
```
* Remove old Docker images
```bash
    rm -rf /var/lib/docker
    rm -rf /opt/datarobot/registry
```
* Remove old configuration files
```bash
    rm -rf /opt/datarobot/etc/
```

## Update configuration files

Your `config.yaml` will need to be updated.
Contact DataRobot Support to identify required changes.

Remove the following keys, if present:

    USER_MODEL_CONTEXT_BASE
    SECURE_WORKER_USER_TASK_IMAGE
