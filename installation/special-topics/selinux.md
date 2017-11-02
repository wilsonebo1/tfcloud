# SELinux

DataRobot supports SELinux enforcing for Centos and Redhat 7.

## SELinux Background

Security-Enhanced Linux (SELinux) is a kernel-based system for managing access
controls in Linux, beyond the limitations of user, group, and file
permissions. It allows for more subtle control, like granting certain processes
access to certain ports or directories. These are known as an SELinux context,
which defines the name, role, and domain for users and processes.

Files, network ports, and other hardware can also have SELinux *contexts*
associated with them. These have a *name*, *role*, and *type*. File contexts are
also known as labels, and the act of relabeling a file context grants read or
write permissions to different users or processes. This is necessary for
Docker containers, which relabel volumes that are mounted into the
containers from the host system to work with SELinux.

SELinux policies define access controls for users, processes, files,
network ports, etc. When an access violation occurs, it is written to an
audit log (typically `/var/log/audit/audit.log`).

A SELinux-compatible Linux kernel and distribution supports different modes:

* **Permissive**: SELinux does not prevent contextual access violations,
but does write them to a log
* **Enforcing**: SELinux prevents contextual access violations and
writes to an audit log

Operating in permissive mode is supported. Operation in enforcing mode
also is supported, as long as the SELinux policy and management
requirements are met.

A more detailed background on SELinux can be found
[here](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/SELinux_Users_and_Administrators_Guide/).

## SELinux Policy Requirements

DataRobot uses Docker containers for many services. The containers must be
granted a level of contextual access to operate, including connecting to
sockets and relabeling files/directories.

Additionally, `rsyslog` is used for logging, and must be allowed to access
directories and sockets.

On an selinux enabled system, DataRobot will automatically install a compatible selinux policy during installation of dependencies (e.g., running `./bin/datarobot setup-dependencies`).

The installed policy will be similar to the one shown below:

```
# FILE: datarobot.te
module datarobot 4.0;
require {
    type docker_t;
    type logrotate_t;
    type svirt_lxc_net_t;
    type syslogd_t;
    type unlabeled_t;
    type unreserved_port_t;
    type usr_t;
    class chr_file { rename unlink };
    class dir { add_name create read relabelfrom relabelto remove_name rename reparent rmdir setattr write };
    class fifo_file setattr;
    class file { append create getattr ioctl link open relabelfrom relabelto rename setattr unlink write };
    class lnk_file { create relabelfrom relabelto rename setattr unlink };
    class chr_file { rename unlink };
    class sock_file { create setattr };
    class udp_socket name_bind;
    class unix_stream_socket connectto;
}

allow svirt_lxc_net_t docker_t:fifo_file setattr;
allow svirt_lxc_net_t docker_t:unix_stream_socket connectto;
allow svirt_lxc_net_t usr_t:dir { add_name create relabelfrom relabelto remove_name rename reparent rmdir setattr write };
allow svirt_lxc_net_t usr_t:file { create link relabelfrom relabelto rename setattr unlink write };
allow svirt_lxc_net_t usr_t:chr_file { rename unlink };
allow svirt_lxc_net_t usr_t:lnk_file { create relabelfrom relabelto rename setattr unlink };
allow svirt_lxc_net_t usr_t:sock_file { create setattr };

allow logrotate_t unlabeled_t:dir read;
allow syslogd_t unlabeled_t:dir { add_name write };
allow syslogd_t unlabeled_t:file { append create getattr ioctl open write };
allow syslogd_t unreserved_port_t:udp_socket name_bind;
```

## SELinux Management Requirements

DataRobot also requires you run some SELinux management commands to operate.
These depend on the state set up during installation, so they must be run *after running* `./bin/datarobot setup-dependencies`.
This allows `rsyslog` to work on a variant port (1514), accept logs from services, and write to the DataRobot logs directory (e.g. `/opt/datarobot/logs`).

The recommended procedure to enable this functionality and restart `rsyslog` for the changes to take effect is to run the following commands on all instances after provisioning them (e.g., running `./bin/datarobot setup-dependencies`):

```bash
sudo semanage port -a -t syslogd_port_t -p udp 1514
sudo semanage fcontext -a -t syslogd_var_lib_t "/opt/datarobot/logs(/.*)?"
sudo restorecon -R -v /opt/datarobot/logs
sudo service rsyslog restart
```
