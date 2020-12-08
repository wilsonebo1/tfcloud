# DataRobot Linux Installation {#linux-install}

The following steps are required for all DataRobot installations.
Refer to supplementary material for any extra configuration requirements, such as [enabling TLS](./special-topics/tls.md), [Hadoop integration](./hadoop-install.md), or [Kubernetes setup](./kubernetes-install.md).

## Cluster Preparation {#linux-prep}

To prepare the cluster for installation, we will create configuration files and install and configure system dependencies.

First, ensure all nodes in your cluster meet the requirements specified in the [Linux Application Server Requirements](./requirements/system-requirements.md#linux-requirements)
section.

### SELinux

If SELinux is installed and enforcing mode is desired, follow instructions for [SELinux](./special-topics/selinux.md).

If enforcing mode is not desired and SELinux is installed, configure SELinux for permissive mode:

```bash
sudo setenforce Permissive
```

Additionally, configure permissive boot after reboot:

```bash
sudo sed -i --follow-symlinks 's/SELINUX=Enforcing/SELINUX=Permissive/' /etc/sysconfig/selinux
```

### Copy Artifact

* Copy the DataRobot package to a directory on the install server.
In this install guide we will assume the directory is `/opt/datarobot/DataRobot-6.x.x/`.
If you use a different directory, replace `/opt/datarobot/DataRobot-6.x.x/` in the following commands with your directory.

Ensure the destination has at least 15 GB of free space for the file and its extracted contents:

```bash
scp DataRobot-RELEASE-*.tar.gz \
    datarobot@[INSTALL SERVER IP]:/opt/datarobot/DataRobot-6.x.x/
```

Also transfer the sha1sum file, to verify the integrity of the installation package:

```bash
scp DataRobot-RELEASE-*.tar.gz.sha1sum \
    datarobot@[INSTALL SERVER IP]:/opt/datarobot/DataRobot-6.x.x/
```

* Run the following commands from an SSH session on the install server.
Be sure to use the appropriate ssh key for the `datarobot` user.

```bash
ssh datarobot@[INSTALL SERVER IP]
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

### Create Configuration Files

First, choose a sample YAML configuration file as a template from the `example-configs` directory:

* `single-node-poc.linux.yaml`: Single machine Linux install.

* `multi-node.yaml`: Multiple machine Linux install, with additional examples for more complex setups.

* `single-node-poc.hadoop.yaml`: Single application server install connecting to a Hadoop cluster.

* `multi-node-mlops.yaml`: Multiple machine Linux install, with DataRobot-provided kubernetes for Custom Models on single host.

* `multi-node-ha.yaml`: Multiple application servers.

Now, copy it to `/opt/datarobot/DataRobot-6.x.x/config.yaml`:

```bash
cp example-configs/multi-node.yaml config.yaml
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

**NOTE**: Hostnames (aside from `webserver_location`, if specified), must be IPv4 addresses or DNS hostnames routing to IPv4 addresses.

If DNS hostnames are used for `hosts` in `config.yaml`, an additional value must be set:

```yaml
# Example config.yaml snippet
---
os_configuration:
  web_api_ip: ip
```

Where `ip` is the IPv4 address of the host running the `internalapi` service.

The `example-configs/config-variables.md` file has a comprehensive set of documented configuration values.

#### SSL/TLS Encryption

Note: if your DataRobot installation is accessed from the Internet, as opposed to a internal network, you _must_ use TLS (Transport Layer Security) encryption to prevent exposing data and unauthorized access to your cluster.
For instructions on setting up TLS encryption on your webserver, see the Advanced Configuration [section on TLS](special-topics/tls.md).

Contact DataRobot Support if you have any questions about settings in this file.

#### Configuring Webserver Privilege and Ports

By default, the webserver (`nginx`) runs on privileged ports (80 for http, 443 for https).

This can be configured. It is possible to run `nginx` on non-privileged ports (typically >=1024 on most distributions).
For example, port `8080` can be used for http, and port `8443` for https (any non-privileged ports can be used).
This can be configured in `config.yaml`:

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


### Install Dependencies

* Run the dependency installation command.
It should take several minutes to complete.

```bash
./bin/datarobot setup-dependencies
```

If performing an offline installation using local connection, you must skip the support environment setup.

```bash
./bin/datarobot setup-dependencies --skip-support-setup
```

A successful run of this command will finish with:

```bash
Playbook completed successfully
DataRobot dependencies setup completely.
```

* Start the Docker registry:

```bash
./bin/datarobot run-registry
```

A successful run of this command will finish with:

```bash
Playbook completed successfully
DataRobot registry setup complete.
```

### Execute Pre-flight Checks

* Verify that everything is configured correctly:

```bash
./bin/datarobot health cluster-checks --deps-installed
```
A successful run of this command will finish with:
```bash
Playbook completed successfully

Cluster has passed all pre-flight checks
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
A successful run of this command will finish with:
```bash
Playbook completed successfully
DataRobot Installation Complete.
```

**NOTE**: If performing an offline install, run all of these commands on each machine. Additionally, you may need to perform a final
`bin/datarobot services restart` on each machine after completing installation on all machines.


* Check that the cluster was installed correctly:

```bash
./bin/datarobot health smoke-test
```

* Run the command to generate the initial admin account for the DataRobot application:

```bash
./bin/datarobot users reset-admin-credentials
```

## Complete and Test

Application server installation complete!

If this is a Linux-only installation, DataRobot is now ready to use.
If this is a Hadoop installation, refer to the [Hadoop Installation](./hadoop-install.md) section to continue with the installation process.
If this is a Kubernetes installation, refer to the [Kubernetes Installation](./kubernetes-install.md) section to continue with the installation process.

* You can now open the DataRobot application in your web browser by pointing it to `http://[INSTALL SERVER FQDN OR IP ADDRESS]` and logging in using the credentials printed out by the previous command. You should use this account for creating new users and modifying user permissions only.

Sample datasets can be downloaded as follows:

* <https://s3.amazonaws.com/datarobot_public_datasets/10k_diabetes.xlsx> (use _"readmitted"_ as your target variable)
* <https://s3.amazonaws.com/datarobot_test/kickcars-sample-200.csv> (use _"isBadBuy"_ as your target variable)

Please refer to the Administration Manual to learn how to administer your installation.
