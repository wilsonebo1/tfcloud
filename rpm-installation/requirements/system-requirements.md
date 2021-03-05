# DataRobot System Requirements

This section describes the software and infrastructure requirements for running the DataRobot application.
It assumes you have provisioned sufficient hardware resources to run large computational workloads.

# Linux Application Server {#linux-requirements}

## Linux Distribution

DataRobot officially supports RedHat and CentOS versions 7.9 and 8.2.
Other versions are supported via contract addendum.

Your Linux server must have access to up-to-date repository servers with standard RedHat packages.

Additionally, access to the following packages and their dependencies are required.

```bash
bzip2, bzip2-libs, ca-certificates, curl, cyrus-sasl, db4, file, freetype, gdbm, glibc, gmp, gpgme, libaio, libcurl,
libffi, libgcc, libgfortran, libgomp, libpcap, libpng, libstdc++, libuuid, libXft, libxml2, mysql, mysql-libs, ncurses,
net-tools, numactl, openssl, readline, snappy, sqlite, tar, tk, uuid, wget, xz, zlib
```

These packages are available on [Extra Packages for Enterprise Linux (EPEL)](https://fedoraproject.org/wiki/EPEL) for CentOS/RHEL 7/8.

**NOTE**: On RHEL7, the `libdb4` package provides `db4` and there is no package named `db4` for RHEL7.

We recommend making the latest stable version from EPEL available in your internal repositories if you are not using EPEL.

## Shell

You must have access to a shell (`/bin/bash` is preferred).

## Users

DataRobot requires a user to run services. Typically, this user is named `datarobot`.
This user is _not created_ during the RPM and Hadoop installation process.
This user must own the DataRobot installation directory, `/opt/datarobot`.

A _separate_ admin user (or `root`) must be provided by the customer for running privileged installation and administration commmands.
It will be assumed that this user is used when running any commands in these instructions unless otherwise specified.
This user _must_ be able to execute any commands with `sudo` (or be `root`).
We recommend an admin user with `sudo` access is used instead of logging in and running commands as `root`, which
may require some manual changes beyond the scope of this document
(e.g. with permissions, or modification of `ansible` roles/playbooks).
For illustration purposes, we will use the username `dradmin` throughout this documentation.

The user may be a system user, but keep in mind you will want to set a default shell for the user.
This user must have access to the following:

* Enable sudo for the admin user.

```bash
echo 'dradmin ALL=(ALL) NOPASSWD: ALL' >> ./dradmin
chown root:root dradmin
sudo mv dradmin /etc/sudoers.d/
```

* Passwordless SSH access to all nodes in the cluster, even in single-node environment.
Please ensure there is no SSH timeout; some SSH commands take a long time to run, particularly if disk access is slow.
If there is an SSH timeout, it must be greater than 45 minutes.

```bash
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

## Disk Space

DataRobot requires a minimum of free disk space available at the following paths:

- /opt/datarobot - 80 GiB;

For data storage nodes (running `HDFS`, etc.), we recommend a minimum of 4TB of free space for production-ready systems.

## Files

| Description | Filename | Notes |
|:------------|:---------|:------|
| DataRobot Distribution | DataRobot-RELEASE-7.x.x-rpm.tar.gz | A tarball containing all files required for DataRobot installation |

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
