# Unprivileged User Installation

DataRobot requires escalated privileges to install dependency packages,
configure system limits, and configure logging on your system.

If you can't enable passwordless `sudo` for the DataRobot service user, you
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

{% block admin_user_docker %}
After performing these steps, verify everything is working correctly with:

```bash
./bin/datarobot health cluster-checks
```

## Prepare the Ansible Interpreter

DataRobot 6.2+ relies on a portable Quantum Python interpreter to be used as 
the Ansible Python interpreter on all cluster hosts. 
 
**Note**: If preforming an Offline Installation using Local Connection these 
steps are unnecessary as you have already provided an alternative interpreter 
location via `config.yaml`.

* Prepare the `release/venv` for transfer:

```bash
cd /opt/datarobot/DataRobot-7.x.x/release
find -L venv/ -type f ! -name "*.pyc" | tar -czvf release_venv.tar.gz -T -
```

* Copy `release_venv.tar.gz` to all application servers.

* On all nodes, delete any previous interpreter and install the new virtualenv
under the `support/release` directory of the DataRobot home:

```bash
sudo rm -rf /opt/datarobot/support/
mkdir dir -p /opt/datarobot/support/release/
tar -xzvf release_venv.tar.gz -C /opt/datarobot/support/release/
```

* Recursively change ownership of the new interpreter to the DataRobot service
user:

```bash
sudo chown -R datarobot:datarobot /opt/datarobot/support/
```

## Install Docker

Docker Engine version 19.03+ must be installed on all Edge Nodes.

* Copy the folder `release/docker-packages/RedHat-7/` or `release/docker-packages/RedHat-8/` to all application
servers.

* On all nodes, run the following commands:

```bash
cd /opt/datarobot/DataRobot-7.x.x/
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

### Docker

* Modify the file `/etc/docker/daemon.json` with the following:

```json
{
    "group": "docker",
    "insecure-registries": [
        "<IP of application server>:5000"
    ],
    "storage-driver": "overlay2",
    "selinux-enabled": true,
    "log-driver": "syslog"
}
```

### Docker Permissions

Ensure that your install user has permissions to run Docker commands.

The file `/var/run/docker.sock` should be owned by a group that your DataRobot user is in.
By default the file will be owned by the `docker` group.
If you would like to use a different group name, run the following on all nodes with your choices of group name and DataRobot user name:

Modify your `/etc/docker/daemon.json` to include the following:

```json
{
    "group": "mydockergroup"
}
```

```bash
sudo groupadd mydockergroup
sudo usermod -aG mydockergroup datarobot
sudo service docker restart
```

Verify that your DataRobot user can access the Docker daemon on all nodes by
logging in as your DataRobot user and running:

```bash
sudo su - datarobot
docker info
```

You should see information about Docker’s configuration.

Now add the following parameter to the root level of your `config.yaml` file:

```yaml
docker_group_name: mydockergroup
```
## Directories

Ensure the following directories exist and are owned by the DataRobot user
with `755` permissions. All paths are relative to the
`os_configuration.datarobot_home_dir` setting in your `config.yaml` or
the default `/opt/datarobot` if that is not set.

```bash
sudo su - datarobot
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

RSYLSOG is used to collect logs from all running DataRobot services and the
hadoop cluster. Services forward `STDOUT` and `STDERR` to the local host's
syslog via the `daemon` logging facility. RSYSLOG filters these logs and writes them to
local files as well as forwarding them to a central syslog server.

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
$template CCMJSON_MSG,"%msg:9:999999999%\n"
$template DRJSON_MSG,"%msg:8:999999999%\n"
$template DSMJSON_MSG,"%msg:9:999999999%\n"
$template DSSJSON_MSG,"%msg:9:999999999%\n"
$template DRMJSON_MSG,"%msg:9:999999999%\n"
$template ETLJSON_MSG,"%msg:9:999999999%\n"
$template DRAUDIT_MSG,"%msg:20:999999999%\n"
$template POUXJSON_MSG,"%msg:10:999999999%\n"
$template YARNPLAIN_MSG,"%msg:9:999999999%\n"

$template JSON_MSG,"%msg%\n"

# Set logs to be owned by datarobot
# To avoid all other rsyslog configs being set to datarobot,
#    we set to root at the bottom of this config.

$FileOwner datarobot
$FileGroup datarobot




:msg, contains, "CCMJSON" /opt/datarobot/logs/ccm.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "DRAUDIT-gon0DRO4Pb" /opt/datarobot/logs/audit.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "DRJSON" /opt/datarobot/logs/datarobot.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "DSMJSON" /opt/datarobot/logs/dynamic-scaling-manager.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "DSSJSON" /opt/datarobot/logs/datasets-service.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "DRMJSON" /opt/datarobot/logs/hadoop-master.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "NGINXJSONLOGS" /opt/datarobot/logs/nginx.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "INTERNALNGINXJSONLOGS" /opt/datarobot/logs/nginx.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "PREDAPINGINXJSONLOGS" /opt/datarobot/logs/nginx.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "POUXJSON" /opt/datarobot/logs/poux.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "YARNPLAIN" /opt/datarobot/logs/hadoop-containers.log
& /opt/datarobot/logs/all.log
& stop

:app-name, contains, "pngexportworker" /opt/datarobot/logs/pngexport.log;JSON_MSG
& /opt/datarobot/logs/all.log
& stop



# This sets FileOwner and FileGroup to root/adm for 53+ level services
# Better than accidentally being set to datarobot

$FileOwner root
$FileGroup root
```

On all other servers, write the following file:

```
# FILE: /etc/rsyslog.d/53-logging.conf
$template CCMJSON_MSG,"%msg:9:999999999%\n"
$template DRJSON_MSG,"%msg:8:999999999%\n"
$template DSMJSON_MSG,"%msg:9:999999999%\n"
$template DSSJSON_MSG,"%msg:9:999999999%\n"
$template DRMJSON_MSG,"%msg:9:999999999%\n"
$template ETLJSON_MSG,"%msg:9:999999999%\n"
$template DRAUDIT_MSG,"%msg:20:999999999%\n"
$template POUXJSON_MSG,"%msg:10:999999999%\n"
$template YARNPLAIN_MSG,"%msg:9:999999999%\n"

$template JSON_MSG,"%msg%\n"

# Set logs to be owned by datarobot
# To avoid all other rsyslog configs being set to datarobot,
#    we set to root at the bottom of this config.

$FileOwner datarobot
$FileGroup datarobot






:msg, contains, "CCMJSON" @LOG_SERVER:1514;CCMJSON_MSG
& /opt/datarobot/logs/ccm.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "DRAUDIT-gon0DRO4Pb" @LOG_SERVER:1514;DRAUDIT_MSG
& /opt/datarobot/logs/audit.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "DRJSON" @LOG_SERVER:1514;DRJSON_MSG
& /opt/datarobot/logs/datarobot.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "DSMJSON" @LOG_SERVER:1514;DSMJSON_MSG
& /opt/datarobot/logs/dynamic-scaling-manager.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "DSSJSON" @LOG_SERVER:1514;DSSJSON_MSG
& /opt/datarobot/logs/datasets-service.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "DRMJSON" @LOG_SERVER:;DRMJSON_MSG
& /opt/datarobot/logs/hadoop-master.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "ETLJSON" @LOG_SERVER:;ETLJSON_MSG
& /opt/datarobot/logs/dssetl.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "NGINXJSONLOGS" @LOG_SERVER:;JSON_MSG
& /opt/datarobot/logs/nginx.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "INTERNALNGINXJSONLOGS" @LOG_SERVER:;JSON_MSG
& /opt/datarobot/logs/nginx.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "PREDAPINGINXJSONLOGS" @LOG_SERVER:;JSON_MSG
& /opt/datarobot/logs/nginx.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "POUXJSON" @LOG_SERVER:1514;POUXJSON_MSG
& /opt/datarobot/logs/poux.log
& /opt/datarobot/logs/all.log
& stop

:msg, contains, "YARNPLAIN" @LOG_SERVER:;YARNPLAIN_MSG
& /opt/datarobot/logs/hadoop-containers.log
& /opt/datarobot/logs/all.log
& stop

:app-name, contains, "pngexportworker" @LOG_SERVER:1514;JSON_MSG
& /opt/datarobot/logs/pngexport.log
& /opt/datarobot/logs/all.log
& stop

:app-name, contains, "appsconductor" @LOG_SERVER:1514;JSON_MSG
& /opt/datarobot/logs/appsconductor.log
& /opt/datarobot/logs/all.log
& stop

:app-name, contains, "appsconductor" @LOG_SERVER:1514;JSON_MSG
& /opt/datarobot/logs/appsconductor.log
& /opt/datarobot/logs/all.log
& stop




# This sets FileOwner and FileGroup to root/adm for 53+ level services
# Better than accidentally being set to datarobot

$FileOwner root
$FileGroup root
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

## SELinux

Follow these steps [here](selinux.md#SELinux-Unpriviledged-User) in order to install the DataRobot SELinux policy.

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
# DataRobot predictions data spool files cleanup
0 2 */1 * * test -d /opt/datarobot/data/predictions_data/modmon-stats && find /opt/datarobot/data/predictions_data/modmon-stats -mindepth 1 -mtime +1 -exec rm -rf {} \;
```

In the root user's crontab, put the following line to rebuild iptables rules at reboot

```
# FILE: root user's crontab
#Ansible: Recreate execution environment builder iptables rules
@reboot /opt/datarobot/bin/environment-builder-iptables.sh
```

## System Limits

DataRobot requires the ability to open a large number of files simultaineously
and the ability to leverage large locked-in-memory address spaces. Set the
following system limits in order to avoid 'Out of Memory' and 'Too Many Open Files'
errors.

```
# FILE: /etc/security/limits.d/99-datarobot.conf
*      -      memlock unlimited
*      -      nofile  65536
```

DataRobot also leverages memory-mapped file I/O for processing.  The default
operating system limits on mmap counts is likely to be too low, which may
result in out of memory exceptions.  Set the following mmap limits to avoid
Out of Memory errors.

```
# FILE: /etc/sysctl.d/99-datarobot.conf
vm.max_map_count=262144
```

DataRobot is not certified to work in environments running IPv6.  Use the following sysctl settings to disable IPv6 on all hosts running DataRobot services.

```
#FILE: /etc/sysctl.d/99-datarobot.conf
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
```

Load the `/etc/sysctl.d/99-datarobot.conf` sysctl parameters on each system running DataRobot services using the following command.

`sysctl -p /etc/sysctl.d/99-datarobot.conf`

Dockers running in the datarobot environment will need to open large numbers
of file simultaineously, as well as accessing locked-in-memory spaces.  Set
the following Docker service parameters to avoid 'Out of Memory' and
'Too Many Open Files' errors.

```
# FILE: /etc/systemd/system/docker.service.d/99-datarobot.conf
[Service]
LimitMEMLOCK=infinity
LimitNOFILE=65536
Restart=on-failure
```

**NOTE**: These settings are general recommendations, your installation
team may ask to increase or change these limits based on your specific
installation and configuration.
