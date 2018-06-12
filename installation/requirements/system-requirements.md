# DataRobot System Requirements

This section describes the software and infrastructure requirements for running the DataRobot application.
It assumes you have provisioned sufficient hardware resources to run large computational workloads.

# Linux Application Server {#linux-requirements}

## Linux Distribution

DataRobot officially supports RedHat 7.2+ and CentOS 7.2+.
Other systems are supported on a best-effort basis.

Your Linux server must have access to up-to-date repository servers with standard RedHat packages.

## Shell

You must have access to a shell (`/bin/bash` is preferred).

## Docker

DataRobot supports Docker version 1.10 and greater.
RPM distributions of Docker Engine 17.03 Community Edition are provided in your installation artifact and will be installed automatically if your server does not already have Docker.

DataRobot ships files and scripts necessary to run a Docker registry containing all images used by the application, so access to Docker Hub or other public registries is not required.

Documentation for Docker can be found at <https://docs.docker.com>.

### Docker Storage

It is important to properly configure Docker storage drivers.
By default, DataRobot will use the `overlay` storage driver.

**NOTE**: Docker requires a filesystem with `d_type` enabled for proper operation.
If you are using an `xfs` filesystem, it must be formatted with `d_type=true`.

One possibility is to use a separate block device or logical volume (e.g. LVM) with Docker.
Consult Docker documentation for more details or contact DataRobot Customer Support.

**NOTE**: Storage setup and disk space requirements are validated when running the pre-flight checker.

See <https://docs.docker.com/engine/userguide/storagedriver/> for more information.

## Users

DataRobot runs all services using the Linux user of your choice.
For illustration purposes, we will use the username `datarobot` throughout this documentation.
The user may be a system user, but keep in mind you will want to set a default shell for the user.
This user must have access to the following:

* A shell (`/bin/bash` preferred)

* Ownership of a directory called `/opt/datarobot` on each node with enough space to install and run the application.

```bash
useradd --create-home --uid 1234 datarobot # uid can be any valid uid
mkdir -p /opt/datarobot /opt/datarobot/DataRobot-4.x.x
chown -R datarobot:datarobot /opt/datarobot
```

* Access to the Docker Engine on the host.

```bash
groupadd docker
usermod -aG docker datarobot
```

* Enable sudo for the datarobot user.

```bash
echo 'datarobot ALL=(ALL) NOPASSWD: ALL' >> ./datarobot
chown root:root datarobot
mv datarobot /etc/sudoers.d/
```

* Passwordless SSH access to all nodes in the cluster, even in single-node environment.
Please ensure there is no SSH timeout; some SSH commands take a long time to run, particularly if disk access is slow.
If there is an SSH timeout, it must be greater than 45 minutes.

```bash
su - datarobot
ssh-keygen -t rsa
# Hit Enter at the prompts
cat .ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
ssh -i ~/.ssh/id_rsa localhost date
# Append id_rsa.pub contents to /home/datarobot/.ssh/authorized_keys on other nodes
# and verify ssh connectivity from the install node.
```

* Ensure that sshd is appropriately configured for public key authentication.

```bash
grep PubkeyAuthentication /etc/ssh/sshd_config
# If a line like "#PubkeyAuthentication yes" appears, you must uncomment the line:
sudo vi /etc/ssh/sshd_config
# Uncomment the line, save and quit
sudo systemctl restart sshd.service
```

If you are not able to give the `datarobot` user access to `sudo` or you have an
alternative privilege escalation tool, see our additional documentation on
installation with
[unprivileged users](../special-topics/admin-user.md#unprivileged-user-installation).

## Software

You must have the following software installed.
Running the following commands should succeed.

* RSYSLOG

```bash
service rsyslog status  # Should show service status
```

* logrotate

```bash
which logrotate  # Should output a path to logrotate
```

* Python 2.7

```bash
python --version
```

The version reported should be a version of `2.7`.

## Disk Space

DataRobot requires a minimum of free disk space available at the following paths:

- /opt/datarobot - 80 GiB;
- /var/lib/docker - 30 GiB.

For data storage nodes (running `gluster`, `HDFS`, etc.),
we recommend a minimum of 4TB of free space for production-ready systems.

## Files

| Description | Filename | Notes |
|:------------|:---------|:------|
| DataRobot Distribution | DataRobot-RELEASE-4.x.x.tar.gz | A tarball containing all files required for DataRobot installation |

## Limits

Recommended limits for various system parameters are below.

#### Open files

There should be at least 65535 open file handles available for processes.
This can be set through through ulimits in `/etc/security/limits.conf`:

```bash
*         hard    nofile      65535
*         soft    nofile      65535
```

#### Number of processes

There should be at least 32768 process numbers availabe.
These can be set through through ulimits in `/etc/security/limits.conf`:

```bash
*      soft   nproc    32768
*      hard   nproc    32768
```

#### Keys in keyrings

Set `root_maxkeys` to at least 1000000.
This can be set through `/etc/sysctl.conf`:

```bash
kernel.keys.root_maxkeys = 1000000
```

## Additional requirements

Make sure there aren't any protocol proxy environment variables set. Usually they go with following names:

```bash
http_proxy
https_proxy
ftp_proxy
rsync_proxy
no_proxy
```

**NOTE**: in most of the cases these names are used in lowercase in contrast to conventional upper case naming for shell environment variables.
But there may be exceptions to this.

You can check their presence by running:

```bash
env | grep -i proxy
```

To unset these for an entire cluster add following lines to `/home/datarobot/.bashrc` file on every node:

```bash
unset http_proxy
unset https_proxy
unset ftp_proxy
unset rsync_proxy
unset no_proxy
```

Also you may want to check if docker daemon is configured to use the variables. Run:

```bash
systemctl show --property=Environment docker
```

If the output contains something like `Environment=HTTP_PROXY=http://proxy.example.com:80/` etc., you should make changes to `/etc/systemd/system/docker.service.d/http-proxy.conf` to mirror your environment configuration.
