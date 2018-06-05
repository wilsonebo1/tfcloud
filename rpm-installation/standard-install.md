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
In this install guide we will assume the directory is `/opt/datarobot/DataRobot-4.2.x/`.
If you use a different directory, replace `/opt/datarobot/DataRobot-4.2.x/` in the following commands with your directory.

Ensure the destination has at least 5 GB of free space for the file and its extracted contents:

```bash
scp DataRobot-RELEASE-*.tar.gz \
    dradmin@[INSTALL SERVER IP]:/opt/datarobot/DataRobot-4.2.x/
```

Also transfer the sha1sum file, to verify the integrity of the installation package:

```bash
scp DataRobot-RELEASE-*.tar.gz.sha1sum \
    dradmin@[INSTALL SERVER IP]:/opt/datarobot/DataRobot-4.2.x/
```

* Run the following commands from an SSH session on the install server.
Be sure to use the appropriate ssh key for the `dradmin` user.

```bash
ssh dradmin@[INSTALL SERVER IP]
```

* Change to the directory where you copied the package.
Execute all the following commands from this directory:

```bash
cd /opt/datarobot/DataRobot-4.2.x/
```

* Verify the integrity of the transferred installation package:

```bash
sha1sum -c DataRobot-RELEASE*.tar.gz.sha1sum
```

If the installation package was transferred without error, you will see a message similar to the following:

```bash
DataRobot-RELEASE-4.2.x.tar.gz: OK
```

If the file was corrupted, you will see a message similar to the following:

```bash
DataRobot-RELEASE-4.2.x.tar.gz: FAILED
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
sudo yum localinstall \
    release/datarobot-rpms/datarobot-common-*.rpm \
    release/datarobot-rpms/datarobot-system-*.rpm
```

### Enable DataRobot CLI Environment

With the RPMs installed, you are now ready to interact with the DataRobot CLI Installer. Load the environment by running:

```bash
source release/profile
```

This must be done once in every new shell session if you wish to use the DataRobot installer (`./bin/datarobot` commands) or tools that are shipped with DataRobot (e.g. anything in `/opt/datarobot/bin` or `/opt/datarobot/sbin`).

### Create Configuration Files

#### Copy From Template
First, choose a sample YAML configuration file as a template from the `example-configs` directory:

* `single-node-poc.linux.yaml`: Single machine Linux install.

* `single-node-poc.hadoop.yaml`: Single application server install connecting to a Hadoop cluster.

The `multi-node` configurations are not supported for RPM installs at this time.

Now, copy it to `/opt/datarobot/DataRobot-4.2.x/config.yaml`:

```bash
cp example-configs/single-node-poc.linux.yaml config.yaml
chmod 0600 config.yaml
```

**NOTE**: The file extension MUST be `yaml`, not `yml`.

* Edit `config.yaml` to suit your particular cluster.

In particular, focus on the user, group, and SSH key settings near the top of the file and the host IP’s near the bottom of the file.

The `admin_user` refers to the user running the installation. They must have the ability to run commands via `sudo` over SSH.
The SSH key specified by `private_ssh_key_path` must be useable by the `admin_user` to SSH into all machines in the cluster and run `sudo` commands.
RPMs will create a `datarobot` user to run services. The `user` and `group` must match `datarobot` for RPM installation.

```yaml
# Example config.yaml snippet
---
os_configuration:
    admin_user: dradmin
    user: datarobot
    group: datarobot
    private_ssh_key_path: /home/dradmin/.ssh/id_rsa
    ...
```

**NOTE**: Hostnames (aside from `webserver_location`, if specified), must be IPv4 addresses.

#### Accept Oracle Java License

Accept the Oracle Binary Code License terms and allow DataRobot to install Oracle Java Development Kit 1.8 by adding `accept_oracle_bcl_terms: yes` to your `config.yaml`.
The license terms can be found on [Oracle's website](http://www.oracle.com/technetwork/java/javase/terms/license/index.html).

```yaml
# Example config.yaml snippet
---
accept_oracle_bcl_terms: yes

os_configuration:
    admin_user: dradmin
    ...
```

The `example-configs/config-variables.md` file has a comprehensive set of documented configuration values.

#### Configure Storage

If you are not doing a Hadoop install, you will need to configure DataRobot to use local storage.

```
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

* Run the following commands in order to install and configure DataRobot:

```bash
# Set up system configuration and install required packages
./bin/datarobot setup-dependencies

# Render configuration files
./bin/datarobot install --pre-configure

# Start DataRobot services
./bin/datarobot services start

# Apply configuration to the running application
./bin/datarobot install --post-configure

# Create the initial admin user
/opt/datarobot/sbin/datarobot-create-admin
```

* You can now open the DataRobot application in your web browser by pointing it to `http://[INSTALL SERVER FQDN OR IP ADDRESS]` and logging in using the credentials printed out by the previous command. You should use this account for creating new users and modifying user permissions only.

If this is a Hadoop installation, refer to the [Hadoop Installation](./hadoop-install.md) section to continue with the installation process.

## Complete and Test

Application server installation complete!

If this is a Linux-only installation, DataRobot is now ready to use.
Please refer to the Administration Manual to learn how to administer your installation.

Sample datasets can be downloaded as follows:

* <https://s3.amazonaws.com/datarobot_public_datasets/10k_diabetes.xlsx> (use _"readmitted"_ as your target variable)
* <https://s3.amazonaws.com/datarobot_test/kickcars-sample-200.csv> (use _"isBadBuy"_ as your target variable)
