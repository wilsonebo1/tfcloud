# DataRobot System Requirements

This section describes the software and infrastructure requirements for running the DataRobot application.
It assumes you have provisioned sufficient hardware resources to run large computational workloads.

The servers and or server instances that are provisioned are expected to be dedicated to DataRobot Enterprise and not running other software products not in direct support of DataRobot Enterprise.

# Linux Application Server {#linux-requirements}

## Linux Distribution

DataRobot officially supports RedHat and CentOS versions 7.9 and 8.2, and RedHat 8.3.
Other versions are supported via contract addendum.

Your Linux server must have access to up-to-date repository servers with standard RedHat packages.

## Shell

You must have access to a shell (`/bin/bash` is preferred).

## Docker

DataRobot supports Docker version 19.03 and greater.

RPM distributions of Docker Engine 19.03 Community Edition are provided in your installation artifact and will be installed automatically if your server does not already have Docker.
We recommend using the version distributed with DataRobot.

DataRobot ships files and scripts necessary to run a Docker registry containing all images used by the application, so access to Docker Hub or other public registries is not required.

Documentation for Docker can be found at <https://docs.docker.com>. WARNING: Antivirus software will cause Docker to hang, and the detail can be found at https://docs.docker.com/engine/security/antivirus/.

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
For illustration purposes, we will use the username `datarobot` as our DataRobot service user throughout this documentation.

On each node of the cluster, starting with the App node, execute the following commands as `root` to provision the DataRobot service user:

1. Create the `datarobot` user.

    ```bash
    useradd --create-home --uid 1234 datarobot # uid can be any valid, consistent uid
    ```

2. Enable docker access for the `datarobot` user.

    ```bash
    groupadd docker
    usermod -aG docker datarobot
    ```

3. Enable sudo for the `datarobot` user.

    If you are not able to give the `datarobot` user access to `sudo` or you have an
alternative privilege escalation tool, see our additional documentation on
installation with
[unprivileged users](../special-topics/admin-user.md#unprivileged-user-installation).

    ```bash
    echo 'datarobot ALL=(ALL) NOPASSWD: ALL' >> ./datarobot
    mv datarobot /etc/sudoers.d/
    ```

4. Set max number of processes, lock memory, and open files for the `datarobot` user.

    ```bash
    echo "datarobot -    nproc   32768" >> /etc/security/limits.d/99-datarobot.conf
    echo "datarobot -    memlock unlimited" >> /etc/security/limits.d/99-datarobot.conf
    echo "datarobot -    nofile  65535" >> /etc/security/limits.d/99-datarobot.conf
    ```

5. Set Docker service parameters to avoid "Out of Memory" and "Too Many Open Files" errors.

    ```bash
    mkdir -p /etc/systemd/system/docker.service.d/
    echo -e "[Service]\nLimitMEMLOCK=infinity\nLimitNOFILE=65536\nRestart=on-failure\n" >> /etc/systemd/system/docker.service.d/1-datarobot.conf
    ```

6. Enable passwordless SSH access.

    ```bash
    mkdir -p /home/datarobot/.ssh && chmod 700 /home/datarobot/.ssh
    ssh-keygen -t rsa -b 2048 -f /home/datarobot/.ssh/id_rsa -N ""
    cat /home/datarobot/.ssh/id_rsa.pub >> /home/datarobot/.ssh/authorized_keys
    chown -R datarobot:datarobot /home/datarobot/.ssh
    chmod 644 /home/datarobot/.ssh/id_rsa.pub
    chmod 600 /home/datarobot/.ssh/id_rsa
    chmod 600 /home/datarobot/.ssh/authorized_keys
    ```

7. Enable public key authentication for sshd.

    ```bash
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    ```

8. Set SSH timeout to 1 hour. Some SSH commands take a long time to run, particularly if disk access is slow. It is recommended to set SSH timeout to greater than 45 minutes.

    ``` bash
    sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 1200/' /etc/ssh/sshd_config
    sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 3/' /etc/ssh/sshd_config
    ```

9. Reload the updated `sshd_config`.

    ```bash
    systemctl reload sshd
    ```

10. Copy `datarobot` public key.

    ```bash
    cat /home/datarobot/.ssh/id_rsa.pub
    # Save the output (to your clipboard, for example).
    ```

11. Add the `datarobot` public key to `authorized_keys` on each node in the cluster by connecting to each one and executing the following:

    ```bash
    sudo su - datarobot
    echo "<the id_rsa.pub string saved in step 13>" >> ~/.ssh/authorized_keys
    ```

12. Test SSH connection to each node. From the App node, execute:

    ```bash
    sudo su - datarobot
    ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa <node-ip> date
    # upon successful connection you should see today's date and time
    ```

## Software
You must have the following software installed. Running the following commands on all nodes in your cluster should return a valid path. If one is not present, the Administrator will need to install and possibly configure it.

```bash
command -v checkpolicy
command -v logrotate
command -v netstat
command -v semanage
command -v rsync
command -v vi
command -v curl
```

## Services
```bash
systemctl status -l rsyslog |grep "Active: "
# This command should return a value if the rsyslog service is running.

systemctl status -l firewalld |grep "Active: "
# If you do not get a value or see "Unit firewalld.service could not be found" that is OK and the following command can be skipped.

# If the firewall is active as shown in the command above, execute:
firewall-cmd --zone=public --list-ports
# Match these ports against the required ports.
```


## Disks and Filesystem
DataRobot requires dedicated hard drive space. For best results:
- All DataRobot volumes must support 50 mb/sec or better throughput using an SSD.
- All DataRobot volumes must have a filesystem that supports D-types such as ext4, or xfs with d_types=true.
- The root drive or `/` should be sized at 40GB minimum.

We also suggest running DataRobot on a separate volume which has been sized according to the provided Spec Sheet by performing the following commands as `root`:

1. Find your name of the volume you intend to use. It should be sized as per the node type.

    ```bash
    lsblk # Examples include nvme1n1 (AWS R5 node types), sdb (AWS R4 node types or GCP), sdc (Used with Azure)
    ```

2. Create a filesystem on the volume and mount it. Steps for mounting an Amazon EBS volume are below. Details can be found in the [Amazon Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html).

    ```bash
    VOLUME=/dev/<volume name> # Where <volume name> = nvme1n1 or sdb or sdc, as shown in the NAME column of the lsblk command above.
    mkfs.ext4 $VOLUME
    mkdir /opt/datarobot
    mount $VOLUME /opt/datarobot
    echo "$(file -s $VOLUME | cut -f 8 -d ' ') /opt/datarobot ext4 defaults,nofail 0 0" >> /etc/fstab
    systemctl daemon-reload
    ```

3. Create the DataRobot install directory.

    ```bash
    mkdir /opt/datarobot/DataRobot-<DataRobot version number> # e.g., 7.2.0
    ```

4. Create docker symlink in order to preserve root disk space.

    ```bash
    mkdir /opt/datarobot/docker
    ln -s /opt/datarobot/docker /var/lib/docker
    ```

5. Ensure `datarobot` user is the owner of required directories.

    ```bash
    chown -R datarobot:datarobot /opt/datarobot
    chown -h datarobot:datarobot /var/lib/docker
    ```

For data storage nodes (running minio, HDFS, etc.) we recommend a minimum of 4TB of free space.


## MinIO Encryption Key

MinIO provides encryption-at-rest for data stored in the `minio` service and creates a `minio_sse_master_key` as part of the installation/upgrade process.  The `minio_sse_master_key` is set, and managed, by the DataRobot secrets system and should be regularly backed up.  If this key is lost, access to the data stored in the `minio` subsystem will become inaccessible.  All care should be taken to avoid misplacing or losing the `minio_sse_master_key` as it cannot be regenerated without incurring data loss.

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
| DataRobot Distribution | DataRobot-RELEASE-7.x.x.tar.gz | A tarball containing all files required for DataRobot installation |

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

## Time Synchronization

Running some standard method of basic time synchronization between hosts (such as `ntpd` or `chronyd`) is a requirement for `DataRobot` application functionality.

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
