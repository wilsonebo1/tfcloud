# DataRobot Linux RPM Installation {#linux-install}

The following steps are required for all DataRobot RPM installations.
Refer to supplementary material for any extra configuration requirements, such as [enabling TLS](./special-topics/tls.md) or [Hadoop integration](./hadoop-install.md).

## Cluster Preparation {#linux-prep}

To prepare the cluster for installation, we will create configuration files and install and configure system dependencies.

First, ensure all nodes in your cluster meet the requirements specficied in the [Linux Application Server Requirements](./requirements/system-requirements.md#linux-requirements)
section.

### SELinux

SELinux in Enforcing mode is not supported for DataRobot installs using RPMs.
Before you begin installation, please disable SELinux or set it to Permissive mode:

```bash
sudo setenforce Permissive
```

Additionally, configure permissive mode to persist after reboot:

```bash
sudo sed -i 's/enforcing/permissive/' /etc/sysconfig/selinux
```

### Copy Artifact

* Copy the DataRobot package to a directory on the install server.
In this install guide we will assume the directory is `/opt/datarobot/DataRobot-6.x.x/`.
If you use a different directory, replace `/opt/datarobot/DataRobot-6.x.x/` in the following commands with your directory.

Ensure the destination has at least 5 GB of free space for the file and its extracted contents:

```bash
scp DataRobot-RELEASE-*.tar.gz \
    dradmin@[INSTALL SERVER IP]:/opt/datarobot/DataRobot-6.x.x/
```

Also transfer the sha1sum file, to verify the integrity of the installation package:

```bash
scp DataRobot-RELEASE-*.tar.gz.sha1sum \
    dradmin@[INSTALL SERVER IP]:/opt/datarobot/DataRobot-6.x.x/
```

* Run the following commands from an SSH session on the install server.
Be sure to use the appropriate ssh key for the `dradmin` user.

```bash
ssh dradmin@[INSTALL SERVER IP]
```

* Change to the directory where you copied the package.
Execute all the following commands from this directory:

```bash
cd /opt/datarobot/DataRobot-6.x.x/
```

* Verify the integrity of the transferred installation package:

```bash
sha1sum -c DataRobot-RELEASE*.tar.gz.sha1sum
```

If the installation package was transferred without error, you will see a message similar to the following:

```bash
DataRobot-RELEASE-6.x.x.tar.gz: OK
```

If the file was corrupted, you will see a message similar to the following:

```bash
DataRobot-RELEASE-6.x.x.tar.gz: FAILED
sha1sum: WARNING: 1 computed checksum did NOT match
```

In this case, the file will need to be downloaded again and transferred to the installation server.

* Extract the package:

```bash
tar xzvf DataRobot-RELEASE*.tar.gz
```

#### SSL/TLS Encryption

**NOTE:** if your DataRobot installation is accessed from the Internet, as opposed to a internal network, you _must_ use TLS (Transport Layer Security) encryption to prevent exposing data and unauthorized access to your cluster.
For instructions on setting up TLS encryption on your webserver, see the Advanced Configuration [section on TLS](special-topics/tls.md).

Contact DataRobot Support if you have any questions about settings in this file.

### Install RPMs

* Run the following command to install the base DataRobot system and installer

```bash
sudo yum localinstall release/datarobot-rpms/datarobot*
```

### Enable DataRobot CLI Environment

With the RPMs installed, you are now ready to interact with the DataRobot CLI Installer. Load the environment by running:

```bash
source release/profile
```

This must be done once in every new shell session if you wish to use the DataRobot installer (`./bin/datarobot` commands) or tools that are shipped with DataRobot (e.g. anything in `/opt/datarobot/bin` or `/opt/datarobot/sbin`).

### Create Configuration Files

First, choose a sample YAML configuration file as a template from the `example-configs` directory:

* `single-node-poc.linux.yaml`: Single machine Linux install.

* `multi-node.yaml`: Multiple machine Linux install, with additional examples for more complex setups.

* `single-node-poc.hadoop.yaml`: Single application server install connecting to a Hadoop cluster.

* `multi-node-ha.yaml`: Multiple application servers (eg. HA databases or dedicated prediction servers).

Now, copy it to `/opt/datarobot/DataRobot-6.x.x/config.yaml`:

```bash
cp example-configs/multi-node.yaml config.yaml
chmod 0600 config.yaml
```

**NOTE**: The file extension MUST be `yaml`, not `yml`.

* Edit `config.yaml` to suit your particular cluster.

In particular, focus on the user, group, and SSH key settings near the top of the file and the host IP’s near the bottom of the file.

DataRobot requires a user to run services, referred to as `user` in `config.yaml` (along with it's group, `group`).
Typically, this user is named `datarobot`, but any username is valid. RPMs will _not_ create a `datarobot` user/group.
This user must be created manually. This user must own the DataRobot installation directory, `/opt/datarobot`.
Typically, this means `/opt/datarobot` is the `HOME` directory of this user.
To create this user manually, if it does not already exist:

```bash
useradd -d /opt/datarobot datarobot
```

The `user` refers to the user which services run as, and is used for parts of the installation that do not require privilege (`sudo`). The SSH key
specified by `private_ssh_key_path` must be usable by the `user` to SSH into all machines in the cluster, unless an offline installation is performed.

The `admin_user` refers to the user running privileged parts of the installation (such as requiring `sudo`, etc.).
They must have the ability to run commands via `sudo` over SSH, unless an offline installation is performed.
The SSH key specified by `admin_private_ssh_key_path` must be usable by the `admin_user` to SSH into all machines in the cluster and run `sudo` commands.

```yaml
# Example config.yaml snippet
---
os_configuration:
    admin_user: dradmin
    user: datarobot
    group: datarobot
    admin_private_ssh_key_path: /home/dradmin/.ssh/id_rsa
    private_ssh_key_path: /opt/datarobot/.ssh/id_rsa
    ...
```

**NOTE**: Hostnames (aside from `webserver_location`, if specified), must be IPv4 addresses.

The `example-configs/config-variables.md` file has a comprehensive set of documented configuration values.

#### Configure Storage

If you are not doing a Hadoop install, you will need to configure DataRobot to use local storage.

```yaml
# Example config.yaml snippet
---
...
app_configuration:
    drenv_override:
        FILE_STORAGE_TYPE: local
        LOCAL_FILE_STORAGE_DIR: /opt/datarobot/data
        FILE_STORAGE_PREFIX: storage/  # Trailing slash required
...
```

#### Configuring Webserver Privilege and Ports

By default, the webserver (`nginx`) runs as the privileged user (`admin_user`), runs on privileged ports (80 for http,
443 for https), uses `setcap` to allow `user` to bind to those ports, then uses `sudo` to drop privileges and run `nginx`
as `user.

This can be configured. It is possible to run `nginx` on non-privileged ports (typically >=1024 on most distributions).
This avoids running `setcap`/`sudo` and just starts `nginx` as `user`. For example, port `8080` can be used for http, and
port `8443` for https (any non-privileged ports can be used). This can be configured in `config.yaml`:

```yaml
# Example config.yaml snippet
---
...
os_configuration:
  webserver:
    http_port: 8080
    https_port: 8443
    privileged: false
  webserver_hostname: hostname-to-use:8443
```

#### Offline Installation using Local Connection

It is possible to avoid using SSH, for example in offline installation. When this is done, installation must be done
on each machine separately (following the full installation instructions on each machine). Additionally, the ansible
connection must be set to `local`. This can be done for each host in `config.yaml`, by converting the `hosts` list
from strings (e.g. `- 10.1.2.3`) into mappings of the address (e.g. `- address: 10.1.2.3`) and overriding ansible
variables. For example:

```yaml
# Example config.yaml snippet
---
...
servers:
  ...
  hosts:
  - address: 10.1.2.3
    ansible_vars:
      ansible_connection: local
      ansible_python_interpreter: /opt/datarobot/DataRobot-x.x.x/release/venv/bin/python
...
```

#### Validate Configuration

To validate your configuration files, run

```bash
./bin/datarobot validate
```

**NOTE**: Although the validation is very comprehensive regarding the aspects of semantics and particular attribute values, there are still situations where invalid user-provided configuration will not be detected.
This can cause unexpected results during deployment/usage.
One such situation is a YAML configuration file with an extra indent step.
This may lead to an optional key being absent because it is shifted into the object above it.
Please manually verify that the correct level of indentation is used in all YAML files.


## Install and Configure the Application {#linux-provision}

* As the `admin_user`, set up system configuration and install required packages and service definitions:

```bash
./bin/datarobot setup-dependencies
```

* As the `user`, install and configure DataRobot:

```bash
source release/profile

./bin/datarobot install --pre-configure
```

* As the `admin_user`, start DataRobot services:

```bash
./bin/datarobot services start
```

* As the `user`, apply configuration to the running application:

```bash
./bin/datarobot install --post-configure
```

**NOTE**: If performing an offline install, run all of these commands on each machine. Additionally, you may need to perform a final
`bin/datarobot services restart` on each machine after completing installation on all machines.


If an upgrade has been performed, migrate the database schema:

```bash
/opt/datarobot/sbin/datarobot-migrate-db
```

An initial admin user can be created by running:

```bash
/opt/datarobot/sbin/datarobot-create-admin
```

## Complete and Test

Application server installation complete!

If this is a Linux-only installation, DataRobot is now ready to use.
If this is a Hadoop installation, refer to the [Hadoop Installation](./hadoop-install.md) section to continue with the installation process.

* You can now open the DataRobot application in your web browser by pointing it to `http://[INSTALL SERVER FQDN OR IP ADDRESS]` and logging in using the credentials printed out by the previous command. You should use this account for creating new users and modifying user permissions only.

Sample datasets can be downloaded as follows:

* <https://s3.amazonaws.com/datarobot_public_datasets/10k_diabetes.xlsx> (use _"readmitted"_ as your target variable)
* <https://s3.amazonaws.com/datarobot_test/kickcars-sample-200.csv> (use _"isBadBuy"_ as your target variable)

Please refer to the Administration Manual to learn how to administer your installation.
