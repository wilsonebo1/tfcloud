<a name="backup-gluster"></a>
# Backup Gluster
----------------

**NOTE**: As of DataRobot 5.3, Gluster has been deprecated as a filestore backend and will be removed in a future version of the DataRobot Platform.

**NOTE**: Gluster is only supported in docker-based installations.

<a name="a-note-on-docker-storage"></a>
## A note on docker storage
------------------------

The backup/restore procedure uses `tar`. It is _very_ read and write heavy, and runs inside a `docker` container.

It is highly recommended that `overlay2` docker storage is used. In particular, using `devicemapper` (e.g. loopback mode), expect _dramatic_ increase in the time to create a backup and restore. This could take three times as long or longer than if `overlay2` is used!

<a name="backup-gluster-quickstart"></a>
## Backup Gluster Quickstart
----------------------------
Start the Gluster dockers on all of the data nodes by running the following command on all data backend nodes:

```bash
docker start gluster
```

Backup the Gluster Instance on any one of the data backend nodes with the following command:

```bash
/opt/datarobot/bin/datarobot-manage-gluster -b /opt/datarobot/data/backups/gluster -n backup
```

Stop the Gluster dockers on all of the data nodes by running the following command on all data backend nodes:

```bash
docker stop gluster
```

<a name="backing-up-gluster"></a>
## Backing Up Gluster
------------------
**NOTE**: Backing up a large dataset can take a significant amount of time, so it is recommended that a terminal multiplexer (e.g. `tmux` or `screen`) is used to manage this backup. This will prevent accidental disconnection from interrupting a backup and allow you to check the status of the backup.

`/opt/datarobot/bin/datarobot-manage-gluster` has been provided as a tool to manage Gluster backups. `/opt/datarobot/bin/datarobot-manage-gluster --help` with display all of the configuration options available.  This document will cover the basic backup procedure; you may need to modify command lines to specifically meet the needs of your backup activity and configuration.

You will need a directory large enough to accommodate a backup of the Gluster filesystem.  Testing has shown that compression will typically reduce the size of a Gluster backup by 20%, backing up without compression is significantly faster but requires as much space as the Gluster filesystem consumes.

You only need to execute the backup against a single `gluster` service; the backup command will backup the entire Gluster filesystem across all operational nodes.  Any `gluster` service is acceptable for this backup activity.

On every node configured to host a `gluster` docker, start the `gluster` instance:
```bash
docker start gluster
```

Backing up the Gluster instance should occur on an instance with Gluster already running on it. `docker ps | grep gluster` should return a running gluster docker container.

The following command will initiate a Gluster backup to the `/opt/datarobot/data/backups/gluster` directory, with compression disabled:

```bash
/opt/datarobot/bin/datarobot-manage-gluster -b /opt/datarobot/data/backups/gluster -n backup
```

This command will create a new file `/opt/datarobot/data/backups/gluster/datarobot-gluster-backup-<date>.tar` where `<date>` is today's date in the format `YYYY-DD-MM`.

You can verify that the backup is still in progress by checking the processes running on the host system:

```bash
ps -elf | grep " [t]ar "
```

This will show a running tar process performing the backup.

If compression is not used, the size of the backup tarball will end up being approximately the same as the disk usage of the gluster directory. You can check the current size of the tarball with:

```bash
# check size of gluster directory
du -sh /opt/datarobot/data/gluster

# watch size of tarball increase to meet size of gluster directory
watch ls -lh /opt/datarobot/data/backups/gluster/
```

**NOTE**: If you are running the backup while the DataRobot Platform is still in operation you may see notices similar to the following; these notices simply mean that the application is changing files while the backup occurs.  If you are running a practice backup this is expected; if you expect your application to be offline during the backup it means the application has not yet been shut down completely.

```bash
tar: <directory>: file changed as we read it
tar: <filename>: file changed as we read it
```

Once the backup is complete you can validate that the backup contains all of the files in the Gluster filesystem with the following command:

```bash
/opt/datarobot/bin/datarobot-manage-gluster -b /opt/datarobot/data/backups/gluster -n validate-backup
```

This command will compare the files in the backup archive to the files on the gluster filesystem and generate a report of files that are in the filesystem but are not in the backup.  This will tell you how active the system was during backup activities and how much data will not be restored as part of the migration process.

On every node configured to host a `gluster` docker, stop the `gluster` instance:
```bash
docker stop gluster
```
