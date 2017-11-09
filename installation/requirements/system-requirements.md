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

## Users
DataRobot runs all services using the Linux user of your choice.
For illustration purposes, we will use the username `druser` throughout this documentation.
The user may be a system user, but keep in mind you will want to set a default shell for the user.
This user must have access to the following:

* Ownership of a directory called `/opt/datarobot` on each node with enough space to install and run the application.
```bash
    useradd --create-home --uid 1234 druser # uid can be any valid uid
    mkdir /opt/datarobot /opt/DataRobot-4.0.x
    chown druser:druser /opt/datarobot /opt/DataRobot-4.0.x
```
* Access to the Docker Engine on the host.
```bash
    groupadd docker
    usermod -aG docker druser
```
* Passwordless sudo access
```
    # FILE: /etc/sudoers
    Defaults     !requiretty
    druser       ALL=(ALL) NOPASSWD: ALL
```
* Passwordless SSH access to all nodes in the cluster, even in single-node environment.
```bash
    su druser
    cd ~/
    mkdir ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t rsa
    # Hit Enter at the prompts
    cat .ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 700 ~/.ssh/authorized_keys
    ssh -i ~/.ssh/id_rsa localhost echo "success"
    # Append id_rsa.pub contents to /home/druser/.ssh/authorized_keys on other nodes and verify ssh connectivity from the install node.
```
* A shell (`/bin/bash` preferred)

If you are not able to give the `druser` user access to `sudo` or you have an
alternative privilege escalation tool, see our additional documentation on
installation with
[unprivileged users](../special-topics/admin-user.md#unprivileged-user-installation).

## Software
You must have the following software installed and running

* RSYSLOG
```bash
    service rsyslog status
```
* logrotate
```bash
    which logrotate
```
* GNU Make
```bash
    yum list installed | grep make
```

## Files

| Description | Filename | Notes |
|:------------|:---------|:------|
| DataRobot Distribution | DataRobot-release-4.0.x.tar.gz | A tarball containing all files required for DataRobot installation |
