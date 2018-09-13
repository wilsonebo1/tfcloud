# Network File System (NFS) Support

For non-Hadoop installations, a Network File System (NFS) volume may be used for
``/opt/datarobot/data/app_data`` to be shared among a multiple machine installation.

This is the only directory that is supported for sharing.

It is recommended the NFS volume be configured, mounted, and tested on all machines
prior to an installation, otherwise a re-installation may be required or data
may be lost.

This directory, and all its recursive sub-directories, must be _writable_ by
the ``datarobot`` user prior to installation. It is recommended that it is _owned_
by the ``datarobot`` user.

To enable use of NFS for ``/opt/datarobot/data/app_data``, edit the ``config.yaml`` file
to have the following snippet included, prior to installation:

```yaml
os_configuration:
  nfs:
    enabled: true
```
