# DataRobot System Requirements

This section describes the software and infrastructure requirements for running the DataRobot application.
It assumes you have provisioned sufficient hardware resources to run large computational workloads.

# Linux Application Server {#linux-requirements}

## Linux Distribution

DataRobot officially supports RedHat 7.2+ and CentOS 7.2+.
Other systems are supported on a best-effort basis.

Your Linux server must have access to up-to-date repository servers with standard RedHat packages.

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
mkdir -p /opt/datarobot /opt/datarobot/DataRobot-4.1.x
chown -R datarobot:datarobot /opt/datarobot
```

* Access to the Docker Engine on the host.

```bash
groupadd docker
usermod -aG docker datarobot
```

* Passwordless sudo access (use `sudo visudo`).

```bash
# FILE: /etc/sudoers
Defaults     !requiretty
datarobot    ALL=(ALL) NOPASSWD: ALL
```

* Passwordless SSH access to all nodes in the cluster, even in single-node environment.
Please ensure there is no SSH timeout; some SSH commands take a long time to run, particularly if disk access is slow.
If there is an SSH timeout, it must be greater than 45 minutes.

```bash
su datarobot
cd ~/
ssh-keygen -t rsa
# Hit Enter at the prompts
cat .ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh/authorized_keys
ssh -i ~/.ssh/id_rsa localhost echo "success"
# Append id_rsa.pub contents to /home/datarobot/.ssh/authorized_keys on other nodes
# and verify ssh connectivity from the install node.
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

We recommend a minimum of 100GB free space on all nodes for DataRobot for
production-ready systems.

For data storage nodes (running `gluster`, `HDFS`, etc.),
we recommend a minimum of 4TB of free space for production-ready systems.

## Files

| Description | Filename | Notes |
|:------------|:---------|:------|
| DataRobot Distribution | DataRobot-RELEASE-4.0.x.tar.gz | A tarball containing all files required for DataRobot installation |
