# Unprivileged User Installation

DataRobot requires escalated privileges to install dependency packages,
configure Docker, and configure logging on your system.

If you can't enable passwordless sudo for the DataRobot service user, you
may either specify a separate 'admin user' (to be referred to as `dradmin`)
or manually perform the Manual Configuration steps.

## Admin User

If possible, we recommend creating an admin user with `sudo` access for the
installation process.

* Create a user account that will only be used for the installation process:

```bash
useradd dradmin
```
* Give it passwordless `sudo` access:

```bash
# FILE: /etc/sudoers
Defaults     !requiretty
dradmin      ALL=(ALL) NOPASSWD: ALL
```

* Modify your `config.yaml`

```yaml
# config.yaml snippet
---
os_configuration:
    user: datarobot
    group: datarobot
    private_ssh_key_path: /home/datarobot/.ssh/id_rsa
    admin_user: dradmin
    admin_private_ssh_key_path: /home/dradmin/.ssh/id_rsa
```

If your environment does not allow such a user, you will have to perform a
manual installation.

## Manual Configuration

Follow these instructions to install and configure the DataRobot application if
the Edge Node or Linux-only installation is performed without an admin user
capable of running commands with sudo via SSH.

Once these steps are performed, your cluster will be ready to run the DataRobot
installation process.

You can use these instructions once the initial OS configuration and user setup
is complete and the DataRobot installation media is downloaded and extracted on
the install node.

After performing these steps, verify everything is working correctly with

```bash
./bin/datarobot health cluster-checks
```

## Install Docker

Docker Engine version 1.10+ must be installed on all Edge Nodes.

* Copy the folder `release/docker-packages/RedHat-7/` to all application
servers.

* On all nodes, run the following commands:

```bash
cd /opt/datarobot/DataRobot-4.5.x/
sudo yum localinstall -y --nogpgcheck \
    release/docker-packages/RedHat-7/prereqs/*.rpm
sudo yum localinstall -y --nogpgcheck \
    release/docker-packages/RedHat-7/*.rpm
sudo systemctl enable docker
sudo systemctl start docker
```

## Configure Docker

Configure Docker to use the Docker registry that will run on the Edge Node
and use the syslog driver for container logs.

To do so, modify the daemon options on all Edge Node servers.

### Docker 1.13+

* Modify the file `/etc/docker/daemon.json` with the following:

```json
{
    "group": "docker",
    "insecure-registries": [
        "<IP of application server>:5000"
    ],
    "storage-driver": "overlay",
    "selinux-enabled": true,
    "log-driver": "syslog"
}
```

### Docker Before 1.13

* Modify the file `/etc/sysconfig/docker` with the following:

```bash
# File snippet: /etc/sysconfig/docker
OPTIONS='--selinux-enabled --log-driver=syslog --group=docker --storage-driver=overlay'
INSECURE_REGISTRY='--insecure-registry <IP of application server>:5000'
```

* Restart the Docker service to apply changes:

```bash
sudo systemctl restart docker
```

### Docker Permissions

Ensure that your install user has permissions to run Docker commands.

The file `/var/run/docker.sock` should be owned by a group that your DataRobot
user is in. By default the file will be owned by the `docker` group. If it
isn’t, or you would like to use a different group name, run the following
on all nodes with your choices of group name and DataRobot user name:

```bash
sudo groupadd docker
sudo usermod -aG docker datarobot
sudo service docker restart
```

Verify that your DataRobot user can access the Docker daemon on all nodes by
logging in as your DataRobot user and running:

```bash
sudo su datarobot
docker info
```

You should see information about Docker’s configuration.

## Docker-py

The `docker-py` Python package, used by the installer to issue commands to
Docker, must be present on all application servers.

* Copy the rpm files in `release/docker-packages/docker-py-packages/rpm/`
to all application servers.
* Run the following command on all nodes:

```bash
sudo yum localinstall -y \
release/docker-packages/docker-py-packages/rpm/*.rpm
```

* Add the `docker-py` libraries to site-packages so they are accessible.
(**NOTE**: `cp` may print an error about backports directory.
This can be safely ignored.)

```bash
sudo cp -d /usr/lib/python2.7/dist-packages/* \
    /usr/lib/python2.7/site-packages/
```

## Directories

Ensure the following directories exist and are owned by the DataRobot user
with `755` permissions. All paths are relative to the
`os_configuration.datarobot_home_dir` setting in your `config.yaml` or
the default `/opt/datarobot` if that is not set.

```bash
sudo su datarobot
cd /opt/datarobot
mkdir -p data \
         data/nginx \
         data/ide \
         data/ide/context \
         data/ide/r_lib \
         data/mongo \
         data/user_model/context \
         odbc \
         odbc/environment.d \
         odbc/local_configs \
         DataRobot \
         logs
```

## Logging

RSYLSOG is used to collect logs from all running Docker applications and the
Cloudera cluster. Docker forwards `STDOUT` and `STDERR` from all containers to
the local host’s syslog via the `daemon` logging facility. RSYSLOG filters
these logs and writes them to local files as well as forwarding them to a
central syslog server.

To configure RSYSLOG, add files to `/etc/rsyslog.d/` on each node.

### RSYSLOG on Multiple Servers

If there is more than one node, select one to be the central server for logs.
On this node, write the following files.

```
# FILE: /etc/rsyslog.d/52-server.conf
$ModLoad imudp
$UDPServerRun 1514
```

```
# FILE: /etc/rsyslog.d/53-logging.conf
$template DRJSON_MSG,"%msg:8:999999999%\n"
$template DSSJSON_MSG,"%msg:9:999999999%\n"
$template DRMJSON_MSG,"%msg:9:999999999%\n"
$template JSON_MSG,"%msg%\n"

:msg, contains, "DRAUDIT-gon0DRO4Pb" /opt/datarobot/logs/audit.log
& /opt/datarobot/logs/all.log
& ~

:msg, contains, "DRJSON" /opt/datarobot/logs/datarobot.log
& /opt/datarobot/logs/all.log
& ~

:msg, contains, "DSSJSON" /opt/datarobot/logs/datasets-service.log
& /opt/datarobot/logs/all.log
& ~

:msg, contains, "DRMJSON" /opt/datarobot/logs/hadoop-master.log
& /opt/datarobot/logs/all.log
& ~

:msg, contains, "NGINXJSONLOGS" /opt/datarobot/logs/nginx.log
& /opt/datarobot/logs/all.log
& ~
```

On all other servers, write the following file:

```
# FILE: /etc/rsyslog.d/53-logging.conf
$template DRJSON_MSG,"%msg:8:999999999%\n"
$template DSSJSON_MSG,"%msg:9:999999999%\n"
$template DRMJSON_MSG,"%msg:9:999999999%\n"
$template JSON_MSG,"%msg%\n"


:msg, contains, "DRAUDIT-gon0DRO4Pb" @LOG_SERVER:1514;DRJSON_MSG
& /opt/datarobot/logs/audit.log
& /opt/datarobot/logs/all.log
& ~

:msg, contains, "DRJSON" @LOG_SERVER:1514;DRJSON_MSG
& /opt/datarobot/logs/datarobot.log
& /opt/datarobot/logs/all.log
& ~

:msg, contains, "DSSJSON" @LOG_SERVER:1514;DSSJSON_MSG
& /opt/datarobot/logs/datasets-service.log
& /opt/datarobot/logs/all.log
& ~

:msg, contains, "DRMJSON" @LOG_SERVER:1514;DRMJSON_MSG
& /opt/datarobot/logs/hadoop-master.log
& /opt/datarobot/logs/all.log
& ~

:msg, contains, "NGINXJSONLOGS" @LOG_SERVER:1514;JSON_MSG
& /opt/datarobot/logs/nginx.log
& /opt/datarobot/logs/all.log
& ~
```

Substitute `LOG_SERVER` with the IP address or hostname of the server
chosen to be the central logging server:

### RSYSLOG on Single Application Server

Write the `/etc/rsyslog.d/53-logging.conf` file from the Multiple Servers section.

### Restart RSYSLOG

Once the files are in place, restart the RSYSLOG service on every node:

```bash
sudo service rsyslog restart
```

## Logrotate

On all application servers, configure logrotate to conserve space.

**NOTE**: DataRobot logs are written to the daemon syslog facility.

Review your system’s RSYSLOG configuration (`/etc/rsyslog.conf`
and `/etc/rsyslog.conf.d/`) to see if these messages will end up in any other
log file, such as `/var/log/daemon.log` or `/var/log/messages`, and adjust
your RSYSLOG and logrotate configuration to handle these messages.

DataRobot does not configure your system log rotation or RSYSLOG for you.

An example logrotate configuration is below. Modify it to suit your needs.

```
# FILE: /etc/logrotate.d/datarobot
/opt/datarobot/logs/*.log {
        su root root
        daily
        rotate 30
        compress
        delaycompress
        missingok
        notifempty
        postrotate
            pkill --ns $$ rsyslog -HUP
        endscript
}
```

## Crontab

DataRobot servers cache temporary files to speed up certain operations,
necessitating a cleanup script to run regularly to remove old files from
the cache.

In the DataRobot or root user’s crontab, put the following line to
regularly clean up old files.

```
# FILE: DataRobot user’s crontab
# DataRobot vertex cache cleanup
0 3 */3 * * find /opt/datarobot/data/app_data/uploads -mtime +14 -exec rm {} \;
```
