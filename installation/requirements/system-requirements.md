# DataRobot System Requirements

This section describes the software and infrastructure requirements for running the DataRobot application.
It assumes you have provisioned sufficient hardware resources to run large computational workloads.

The servers and or server instances that are provisioned are expected to be dedicated to DataRobot Enterprise and not running other software products not in direct support of DataRobot Enterprise.

# Linux Application Server {#linux-requirements}

## Linux Distribution

DataRobot officially supports RedHat and CentOS versions greater than or equal to 7.6 and less than 8.
Other systems are supported on a best-effort basis.

Your Linux server must have access to up-to-date repository servers with standard RedHat packages.

## Shell

You must have access to a shell (`/bin/bash` is preferred).

## Docker

DataRobot supports Docker version 1.10 and greater.

RPM distributions of Docker Engine 18.09 Community Edition are provided in your installation artifact and will be installed automatically if your server does not already have Docker.
We recommend using this version.

DataRobot ships files and scripts necessary to run a Docker registry containing all images used by the application, so access to Docker Hub or other public registries is not required.

Documentation for Docker can be found at <https://docs.docker.com>.

### Dependencies

We also ship dependencies related to DataRobot's use of docker. These will be installed by the installer.

If you have automated operating system updates, it is important to prevent the updates from installing different versions of any of the following packages:

```
container-selinux
containerd.io
docker-ce
docker-ce-cli
libnvidia-container-tools
libnvidia-container1
nvidia-container-runtime
nvidia-container-toolkit
nvidia-docker2
python-docker-pycreds
python-websocket-client
python2-docker
python2-requests
python2-six
```

For example, for Centos/RHEL systems, these packages can be excluded from package updates in `/etc/yum.conf`.

```
[main]
# add below line under main section of /etc/yum.conf
exclude=container-selinux* containerd.io* docker-ce* docker-ce-cli* libnvidia-container-tools* libnvidia-container1* nvidia-container-runtime* nvidia-container-toolkit* nvidia-docker2* python-docker-pycreds* python-websocket-client* python2-docker* python2-requests* python2-six*
```

*NOTE:* These dependencies themselves may have additional system dependencies. Any package referenced as a dependency *must not be uninstalled*. These packages and versions may differ on different systems based on operating system distro and version (even minor/patch versions).

For example, for Centos/RHEL systems, after these packages are installed, these package dependencies can be checked with:

```bash
for x in \
    container-selinux \
    containerd.io \
    docker-ce \
    docker-ce-cli \
    libnvidia-container-tools \
    libnvidia-container1 \
    nvidia-container-runtime \
    nvidia-container-toolkit \
    nvidia-docker2 \
    python-docker-pycreds \
    python-websocket-client \
    python2-docker \
    python2-requests \
    python2-six; \
do yum deplist $x | grep provider \
    | sed -e 's/.*provider: //' -e 's/ .*//' -e 's/\..*//' ; \
done | sort | uniq
```

Example output (this may differ based on operating system distro and version):

```
bash
container-selinux
device-mapper-libs
glibc
iptables
iptables-services
libcgroup
libseccomp
libselinux-utils
libtool-ltdl
policycoreutils
policycoreutils-python
python
python-requests
python-six
sed
selinux-policy
selinux-policy-minimum
selinux-policy-mls
selinux-policy-targeted
systemd
systemd-libs
tar
xz
```

### Docker Storage

It is important to properly configure Docker storage drivers.
By default, DataRobot will use the `overlay2` storage driver.

**NOTE**: Docker requires a filesystem with `d_type` enabled for proper operation.
If you are using an `xfs` filesystem, it must be formatted with `ftype=1`.

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
mkdir -p /opt/datarobot /opt/datarobot/DataRobot-5.x.x
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

* checkpolicy

```bash
which checkpolicy  # Should output a path to checkpolicy
```

* logrotate

```bash
which logrotate  # Should output a path to logrotate
```

* net-tools package

```bash
which netstat  # Should output a path to netstat
```

* policycoreutils-python package

```bash
which semanage  # Should output a path to semanage
```

* Python 2.7

```bash

python --version # Should be a version of `2.7`.
```

* rsync

```bash
which rsync  # Should output a path to rsync
```

* rsyslog

```bash
service rsyslog status  # Should show service status
```

* vim

```bash
which vim  # Should output a path to vim
```

* wget

```bash
which wget  # Should output a path to wget
```

## Disk Space

DataRobot requires a minimum of free disk space in these locations:

- DataRobot Home Directory (default `/opt/datarobot`) - 80 GiB
- Docker Data Directory (default `/var/lib/docker`) - 30 GiB

For data storage nodes (running `minio`, `HDFS`, etc.), we recommend a minimum of 4TB of free space for production-ready systems.

## MinIO Encryption Key

MinIO provides encryption-at-rest for data stored in the `minio` service and creates a `minio_sse_master_key` as part of the installation/upgrade process.  The `minio_see_master_key` is set, and managed, by the DataRobot secrets system and should be regularly backed up.  If this key is lost, access to the data stored in the `minio` subsystem will become inaccessible.  All care should be taken to avoid misplacing or losing the `minio_sse_master_key` as it cannot be regenerated without incurring data loss.

## Directories

### DataRobot Home Directory

The default path for the DataRobot home directory is `/opt/datarobot`.

It is used to store the DataRobot installation media and all code, configuration files, and application data.

If `/opt/datarobot` is not on the desired disk partition, it is possible to configure DataRobot to use any alternative directory.
When setting up the `config.yaml` file, set the `os_configuration.datarobot_home_dir` to your desired path.

For ease of administration, it is common to create a symlink named `/opt/datarobot` pointing to your home directory.
However, it is advised to point DataRobot configuration to the real path used and not the symlink.

### Docker Data Directory

Docker defaults to storing images and metadata in `/var/lib/docker`.

If `/opt/datarobot` is not on the desired disk partition, it is possible to create a symlink in your DataRobot home directory as follows.

With a DataRobot home directory of `/data/mydatarobot`:

```bash
mkdir /data/mydatarobot/docker
ln -s /data/mydatarobot/docker /var/lib/docker
```

## Files

| Description | Filename | Notes |
|:------------|:---------|:------|
| DataRobot Distribution | DataRobot-RELEASE-5.x.x.tar.gz | A tarball containing all files required for DataRobot installation |

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
