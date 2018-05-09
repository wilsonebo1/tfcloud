# DataRobot Linux Installation {#linux-install}

The following steps are required for all DataRobot installations.
Refer to supplementary material for any extra configuration requirements, such as [enabling TLS](./special-topics/tls.md) or [Hadoop integration](./hadoop-install.md).

## Cluster Preparation {#linux-prep}

To prepare the cluster for installation, we will create configuration files and install and configure system dependencies.

First, ensure all nodes in your cluster meet the requirements specficied in the [Linux Application Server Requirements](./requirements/system-requirements.md#linux-requirements)
section.

### SELinux

If SELinux is installed and enforcing mode is desired, follow instructions for [SELinux](./special-topics/selinux.md).

If enforcing mode is not desired and SELinux is installed, configure SELinux for permissive mode:

```bash
sudo setenforce Permissive
```

Additionally, configure permissive boot after reboot:

```bash
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=permissive/' /etc/sysconfig/selinux
```

### Copy Artifact

* Copy the DataRobot package to a directory on the install server.
In this install guide we will assume the directory is `/opt/datarobot/DataRobot-4.2.x/`.
If you use a different directory, replace `/opt/datarobot/DataRobot-4.2.x/` in the following commands with your directory.

Ensure the destination has at least 15 GB of free space for the file and its extracted contents:

```bash
scp DataRobot-RELEASE-*.tar.gz \
    datarobot@[INSTALL SERVER IP]:/opt/datarobot/DataRobot-4.2.x/
```

Also transfer the sha1sum file, to verify the integrity of the installation package:

```bash
scp DataRobot-RELEASE-*.tar.gz.sha1sum \
    datarobot@[INSTALL SERVER IP]:/opt/datarobot/DataRobot-4.2.x/
```

* Run the following commands from an SSH session on the install server.
Be sure to use the appropriate ssh key for the `datarobot` user.

```bash
ssh datarobot@[INSTALL SERVER IP]
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
DataRobot-RELEASE-4.0.x.tar.gz: OK
```

If the file was corrupted, you will see a message similar to the following:

```bash
DataRobot-RELEASE-4.0.x.tar.gz: FAILED
sha1sum: WARNING: 1 computed checksum did NOT match
```

In this case, the file will need to be downloaded again and transferred to the installation server.

* Extract the package:

```bash
tar xzvf DataRobot-RELEASE*.tar.gz
```

### Create Configuration Files

First, choose a sample YAML configuration file as a template from the `example-configs` directory:

* `single-node.linux.yaml`: Single machine Linux install.

* `multi-node.linux.yaml`: Multiple machine Linux install, with additional examples for more complex setups.

* `single-node.hadoop.yaml`: Single application server install connecting to a Hadoop cluster.

* `multi-node.hadoop.yaml`: Multiple application servers (eg. HA databases or dedicated prediction servers).

Now, copy it to `/opt/datarobot/DataRobot-4.2.x/config.yaml`:

```bash
cp example-configs/multi-node.linux.yaml config.yaml
chmod 0600 config.yaml
```

**NOTE**: The file extension MUST be `yaml`, not `yml`.

* Edit `config.yaml` to suit your particular cluster.

In particular, focus on the user, group, and SSH key settings near the top of the file and the host IP’s near the bottom of the file.

```yaml
# Example config.yaml snippet
---
os_configuration:
    user: datarobot
    group: datarobot
    private_ssh_key_path: /home/datarobot/.ssh/id_rsa
    ...
```

**NOTE**: Hostnames (aside from `webserver_location`, if specified), must be IPv4 addresses.

The `multi-node.linux.yaml` file has a full set of sample configurations for reference purposes.
The `example-configs/config-variables.md` file has a comprehensive set of documented configuration values.

To validate your configuration files, run

```bash
./bin/datarobot validate
```

**NOTE**: Although the validation is very comprehensive regarding the aspects of semantics and particular attribute values, there are still situations where invalid user-provided configuration will not be detected.
This can cause unexpected results during deployment/usage.
One such situation is a YAML configuration file with an extra indent step.
This may lead to an optional key being absent because it is shifted into the object above it.
Please manually verify that the correct level of indentation is used in all YAML files.

#### SSL/TLS Encryption

Note: if your DataRobot installation is accessed from the Internet, as opposed to a internal network, you _must_ use TLS (Transport Layer Security) encryption to prevent exposing data and unauthorized access to your cluster.
For instructions on setting up TLS encryption on your webserver, see the Advanced Configuration [section on TLS](special-topics/tls.md).

Contact DataRobot Support if you have any questions about settings in this file.

### Install Dependencies

* Run the dependency installation command.
It should take several minutes to complete.

```bash
./bin/datarobot setup-dependencies
```

* Start the Docker registry:

```bash
./bin/datarobot run-registry
```

### Upgrade Existing Mongo Data

If upgrading from a release prior to DataRobot 4.2, the mongo data should now be upgraded.
See the [Mongo Data Upgrade](special-topics/mongo-data-upgrade.md) section for instructions.

### Execute Pre-flight Checks

* Verify that everything is configured correctly:

```bash
./bin/datarobot health cluster-checks --deps-installed
```

## Install and Configure the Application {#linux-provision}

**NOTE**: Before running these steps, perform pre-flight checks to verify that the environment is ready to provision the DataRobot application.

Refer to the [Pre-Flight Checks](./pre-flight-checks.md) guide and return here after successful completion.

With dependencies installed and configured across the application servers, you are ready to configure and run the Docker containers that make up the DataRobot application.

* Run the provision command.
This command should take several minutes to complete:

```bash
./bin/datarobot install
```

* Check that the cluster was installed correctly:

```bash
./bin/datarobot health smoke-test
```

* Run the command to generate the initial admin account for the DataRobot application:

```bash
docker exec app create_initial_admin.sh
```

* You can now open the DataRobot application in your web browser by pointing it to `http://[INSTALL SERVER FQDN OR IP ADDRESS]` and logging in using the credentials printed out by the previous command. You should use this account for creating new users and modifying user permissions only.

Sample datasets can be downloaded as follows:

* <https://s3.amazonaws.com/datarobot_public_datasets/10k_diabetes.xlsx> (use _"readmitted"_ as your target variable)
* <https://s3.amazonaws.com/datarobot_test/kickcars-sample-200.csv> (use _"isBadBuy"_ as your target variable)


Application server installation complete!

If this is a Linux-only installation, DataRobot is now ready to use.
Please refer to the Administration Manual to learn how to administer your installation.

If this is a Hadoop installation, refer to the [Hadoop Installation](./hadoop-install.md) section to continue with the installation process.
