<a name="restore-gluster"></a>
# Restore Gluster
-----------------

**NOTE**: As of DataRobot 5.3, Gluster has been deprecated as a filestore backend and will be removed in a future version of the DataRobot Platform.

**NOTE**: Gluster is only supported in docker-based installations.

<a name="a-note-on-docker-storage"></a>
## A note on docker storage
---------------------------

The backup/restore procedure uses `tar`. It is _very_ read and write heavy, and runs inside a `docker` container.

It is highly recommended that `overlay2` docker storage is used. When using `devicemapper` (e.g. loopback mode), expect a _dramatic_ increase in the time to create a backup and restore. This could take three times as long or longer than if `overlay2` is used!

<a name="restore-gluster-quickstart"></a>
## Restore Gluster Quickstart
-----------------------------
Start the Gluster dockers on all of the data nodes by running the following command on all data backend nodes:

```bash
docker start gluster
```

Backup the Gluster Instance on any one of the data backend nodes with the following command:

```bash
/opt/datarobot/bin/datarobot-manage-gluster \
    -b /opt/datarobot/data/backups/gluster \
    -n restore
```

Stop the Gluster dockers on all of the data nodes by running the following command on all data backend nodes:

```bash
docker stop gluster
```

<a name="gluster-restore"></a>
## Restoring a Backup to Gluster
--------------------------------
Restoring a Gluster instance should occur on an instance with Gluster already running on it. `docker ps | grep gluster` should return a running gluster docker container.

**NOTE**: Restoring up a large dataset can take a significant amount of time, so it is recommended that a terminal multiplexer (e.g. `tmux` or `screen`) are used to manage this restore. This will prevent accidental disconnection from interrupting a restore and allow you to check the status of the restore.

`/opt/datarobot/bin/datarobot-manage-gluster` has been provided as a tool to manage Gluster restores. `/opt/datarobot/bin/datarobot-manage-gluster --help` with display all of the configuration options available.  This document will cover the basic restore procedure; you may need to modify command lines to specifically meet the needs of your restore activity and configuration.

The following command will initiate a Gluster restore from an archive created on January 1, 2019, without compression, and stored in the `/opt/datarobot/data/backups/gluster` directory:
`/opt/datarobot/bin/datarobot-manage-gluster -b /opt/datarobot/data/backups/gluster -f datarobot-gluster-backup-2019-01-01.tar -n restore`

**NOTE**: If the backup was created today you can omit the `-f filename` from the proceeding command.

You can verify that the restore is still in progress by checking the processes running on the host system; `ps -elf | grep " [t]ar "` will show a running tar process performing the restore.

Once the restore is complete you can validate that the restore contains all of the files in the Gluster filesystem with the following command:
`/opt/datarobot/bin/datarobot-manage-gluster -b /opt/datarobot/data/backups/gluster -f datarobot-gluster-backup-2019-01-01.tar -n validate-backup`

This command will compare the files in the archive to the files on the gluster filesystem and generate a report of files that are in the filesystem but are not in the archive.  This will confirm that all backed-up files were restored to the gluster filesystem.
