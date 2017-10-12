# DataRobot Linux Installation {#linux-install}

The following steps are required for all DataRobot installations.
Refer to supplementary material for any extra configuration requirements, such as [enabling SSL](./special-topics/ssl.md) or [Hadoop integration](./hadoop-install.md).

## Cluster Preparation {#linux-prep}

To prepare the cluster for installation, we will create configuration files and install and configure system dependencies.

First, ensure all nodes in your cluster meet the requirements specficied in the [Linux Application Server Requirements](./requirements/system-requirements.md#linux-requirements)
section.

### Copy Artifact

* Copy the DataRobot package to a directory on the install server.
In this install guide we will assume the directory is `/opt/DataRobot-4.0.x/`.
If you use a different directory, replace `/opt/DataRobot-4.0.x/` in the following commands with your directory.

Ensure the destination has at least 15 GB of free space for the file and its extracted contents:

```bash
scp DataRobot-Release-*.tar.gz \
    druser@[INSTALL SERVER IP]:/opt/DataRobot-4.0.x/
```

* Run the following commands from an SSH session on the install server:

```bash
ssh druser@[INSTALL SERVER IP]
```

* Change to the directory where you copied the package.
Execute all the following commands from this directory:

```bash
cd /opt/DataRobot-4.0.x/
```

* Extract the package:

```bash
tar xzvf DataRobot-Release*.tar.gz
```

### Create Configuration Files

* Copy the sample YAML configuration file to `/opt/DataRobot-4.0.x/config.yaml`:

```bash
cp example-configs/multi-node.linux.yaml config.yaml
```

* Or, if you have only one node:

```bash
cp example-configs/single-node-poc.linux.yaml config.yaml
```

**NOTE**: The file extension MUST be `yaml`.

* Edit `config.yaml` to suit your particular cluster.

In particular, focus on the user, group, and SSH key settings near the top of the file and the host IP’s near the bottom of the file.

```yaml
# Example config.yaml snippet
---
os_configuration:
    user: druser
    group: druser
    private_ssh_key_path: /home/druser/.ssh/id_rsa
    ...
```

**NOTE**: Hostnames (aside from `webserver_location`, if specified), must be IPv4 addressses.

The `multi-node.linux.yaml` file has a full set of sample configurations for reference purposes.
The `example-configs/config-variables.md` file has a comprehensive set of documented configuration values.

To validate your configuration files, run

```bash
./bin/datarobot validate
```

Contact DataRobot Support if you have any questions about settings in this file.

### Install Dependencies

* Run the dependency installation command.
It should take several minutes to complete.

```bash
./bin/datarobot setup-dependencies
```

* Verify that everything is configured correctly:

```bash
./bin/datarobot health cluster-checks --deps-installed
```

* Start the Docker registry:

```bash
./bin/datarobot run-registry
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
./bin/datarobot smoke-test
```

* Run the command to generate the initial admin account for the DataRobot application:

```bash
docker exec app create_initial_admin.sh
```

* You can now open the DataRobot application in your web browser by pointing it to `http://[INSTALL SERVER FQDN OR IP ADDRESS]` and logging in using the credentials printed out by the previous command. You should use this account for creating new users and modifying user permissions only.

Application server installation complete!

If this is a Linux-only installation, DataRobot is now ready to use.
Please refer to the [Administration Manual](../administration/README.md) to learn how to administer your installation.

If this is a Hadoop installation, refer to the [Hadoop Installation](./hadoop-install.md) section to continue with the installation process.
