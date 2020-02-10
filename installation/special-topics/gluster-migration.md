<a name="gluster-migration"></a>
Gluster Migration
======================

As of DataRobot 5.3, Gluster has been deprecated as a storage backend and will be removed in a future version of the DataRobot Platform.  This means existing Gluster deployments will be required to migrate from Gluster to a new S3-compatible backend, MinIO.

Scripts have been provided to backup an existing Gluster deployment and restore it to a running MinIO instance.  These scripts should be run on a host that is currently running Gluster or MinIO; these scripts will not exist on every host.

Gluster is still supported in the DataRobot 6.0 release, and it is recommended that upgrade activities are performed prior to migrating data to the new MinIO backend (i.e. upgrade to 6.0, verify that the upgrade is stable, and then perform the MinIO upgrade).  These tasks do not need to be synchronous, and an extended outage may be required for this backup-and-restore migration.

You must have installed DataRobot 6.0 or later in order to proceed with these migration procedures.

**NOTE**: MinIO provides encryption-at-rest for data stored in the `minio` service and creates a `minio_sse_master_key` as part of the installation/upgrade process.  The `minio_see_master_key` is set, and managed, by the DataRobot secrets system and should be regularly backed up.  If this key is lost, access to the data stored in the `minio` subsystem will become inaccessible.  All care should be taken to avoid misplacing or losing the `minio_sse_master_key` as it cannot be regenerated without incurring data loss.

**NOTE**: Unless otherwise specified all commands here should be run as the non-privileged user (e.g. `user` from `config.yaml`).

This document will cover the basic restore procedure. You may need to modify command lines to specifically meet the needs of your restore activity and configuration.

<a name="a-note-on-docker-storage"></a>
A note on docker storage
------------------------

The backup/restore procedure uses `tar`. It is _very_ read and write heavy, and runs inside a `docker` container.

It is highly recommended that `overlay2` docker storage is used. In particular, using `devicemapper` (e.g. loopback mode), expect _dramatic_ increase in the time to create a backup and restore. This could take three times as long or longer than if `overlay2` is used!

<a name="incremental-copy"></a>
Incremental Copy Quickstart Migration
--------------------
The majority of this migration can be performed while the DataRobot platform is in use. Incremental data copies will put additional load on disk subsystems, as such it is recommended that application performance is monitored during migration activities.  The Incremental Copy Migration requires twice as much disk space as is used prior to the start of migration: one copy of the data will remain active in Gluster and one copy of the data will be active in MinIO.  At the end of the migration you can delete the data store you will no longer use.


Add `minio` to `config.yaml`, set `secrets_enforced` to `true`, and start `minio` services:

```yaml
# config.yaml snippet
os_configuration:
  secrets_enforced: true
```

```yaml
# config.yaml snippet
servers:
  - services:
    - gluster
    - minio
    ...
```

```bash
bin/datarobot setup-dependencies
bin/datarobot install --skip-copy-code
```

Perform the initial synchronization of data:

```bash
/opt/datarobot/bin/datarobot-manage-gluster gluster-sync-to-minio
```
**NOTE**: This step can be performed multiple times and will only copy new data from gluster to minio.  The first time you run this command it will copy all Gluster data to MinIO and may take several hours to complete; the second time you run it only data added after the first synchronization will be copied and the process will be much faster.

Shut down the DataRobot Application:

```bash
bin/datarobot services stop
```

Start the Gluster and MinIO dockers on all of the data nodes by running the following commands on all data backend nodes:

```bash
docker start gluster minio
```

Run a final incremental copy:

```bash
/opt/datarobot/bin/datarobot-manage-gluster gluster-sync-to-minio
```

Stop and remove the `gluster` containers on each Gluster host and stop `minio` containers:
```bash
docker rm -f gluster
docker stop minio
```

Modify your `config.yaml` to remove `gluster` from the DataRobot configuration and change `FILE_STORAGE_TYPE` to `s3`:

```yaml
# config.yaml snippet
servers:
  - services:
      - minio
      ...
```

```yaml
# config.yaml snippet
app_configuration:
  drenv_override:
    FILE_STORAGE_TYPE: s3
    ...
```

Reconfigure and restart the DataRobot instance:

```bash
bin/datarobot setup-dependencies
bin/datarobot run-registry
bin/datarobot install --skip-copy-code
```


<a name="backup-and-restore"></a>
Backup and Restore Quickstart Migration
--------------------
The majority of this migration should be performed while the DataRobot platform is in offline.  Backup-and-restore migration activities will require two to three times as much storage as is initially in use: one copy is active in gluster, one copy is stored in a backup archive, and one copy is stored in minio. (You can remove the copy in gluster once the backup is complete, requiring only twice as much filesystem space).  The backup-and-restore migration is very effective if you are moving from one cluster to a new cluster; it is recommended that you use the [Incremental Copy](#incremental-copy) mechanism if you are migrating data in the same, live cluster.

Add `minio` to `config.yaml`, set `secrets_enforced` to `true`, and start `minio` services:

```yaml
# config.yaml snippet
os_configuration:
  secrets_enforced: true
```

```yaml
# config.yaml snippet
servers:
  - services:
    - gluster
    - minio
    ...
```

```bash
bin/datarobot setup-dependencies
bin/datarobot install --skip-copy-code
```

Shut down the DataRobot Application:

```bash
bin/datarobot services stop
```

Start the Gluster and MinIO dockers on all of the data nodes by running the following commands on all data backend nodes:

```bash
docker start gluster minio
```

Backup the Gluster Instance:

```bash
/opt/datarobot/bin/datarobot-manage-gluster -n backup
```

Restore the Backup to MinIO:

```bash
/opt/datarobot/bin/datarobot-manage-gluster -n restore-s3
```

Stop and remove the `gluster` containers on each Gluster host and stop MinIO with the following commands:
```bash
docker rm -f gluster
docker stop minio
```

Modify your `config.yaml` to remove `gluster` from the DataRobot configuration and change `FILE_STORAGE_TYPE` to `s3`:

```yaml
# config.yaml snippet
servers:
  - services:
      - minio
      ...
```

```yaml
# config.yaml snippet
app_configuration:
  drenv_override:
    FILE_STORAGE_TYPE: s3
    ...
```

Reconfigure and restart the DataRobot instance:

```bash
bin/datarobot setup-dependencies
bin/datarobot run-registry
bin/datarobot install --skip-copy-code
```


<a name="Details"></a>
Details
-------

<a name="add-minio"></a>
Add MinIO Services
------------------
Edit your `config.yaml` to enable secrets and include  `minio` service on each host that has a gluster service. If secrets are not enforced (`secrets_enforced: false`) you will need to change the `false` to `true`

```yaml
# config.yaml snippet
os_configuration:
  secrets_enforced: true
```

```yaml
# config.yaml snippet
servers:
  - services:
    - gluster
    - minio
    ...
```

Run `bin/datarobot install --skip-copy-code` - to create a `minio` instance on each of the nodes currently running a `gluster` service.

If this is an HA configuration with `haproxy` configured, MinIO will leverage HAProxy to create an HA MinIO configuration. (See HA Installation instructions for configuring a HA solution.)


<a name="shutdown-datarobot"></a>
Shutdown DataRobot and Start the Storage Backends
-------------------------------------------------
It is recommended that during the restore process all other DataRobot services be stopped. While DataRobot can continue to execute processes on the Gluster service during backup, changes will not be replicated and could leave DataRobot in an unstable state.

You should consider performing a practice migration by skipping this step. Performing a practice migration will help you to understand the time that will be required for the live migration.  Backup and restore will have an impact on disk performance, so do not schedule your practice migration during a heavy utilization period.

Running `bin/datarobot services stop` will shut down your running DataRobot services across the cluster.

Start the Gluster and MinIO dockers on all of the data nodes by running the following commands on all data backend nodes:

```bash
docker start gluster minio
```

**NOTE**: It is important that all of the `gluster` and `minio` services are started; distributed data requires all of the nodes to be available for both backup and restore activities.

All other services should be offline at this time.

<a name="gluster-backup"></a>
Backing Up Gluster
------------------
Backing up the Gluster instance should occur on an instance with Gluster already running on it. `docker ps | grep gluster` should return a running gluster docker container.

**NOTE**: Backing up a large dataset can take a significant amount of time, so it is recommended that a terminal multiplexer (e.g. `tmux` or `screen`) are used to manage this backup. This will prevent accidental disconnection from interrupting a backup and allow you to check the status of the backup.

`/opt/datarobot/bin/datarobot-manage-gluster` has been provided as a tool to manage Gluster backups. `/opt/datarobot/bin/datarobot-manage-gluster --help` with display all of the configuration options available.  This document will cover the basic backup procedure; you may need to modify command lines to specifically meet the needs of your backup activity and configuration.

You will need a directory large enough to accommodate a backup of the Gluster filesystem.  Testing has shown that compression will typically reduce the size of a Gluster backup by 20%, backing up without compression is significantly faster but requires as much space as the Gluster filesystem consumes.

You only need to execute the backup against a single `gluster` service; the backup command will backup the entire Gluster filesystem across all operational nodes.  Any `gluster` service is acceptable for this backup activity.

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
watch ls -lh /opt/datarobot/data/backups/gluster
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

Once the backup archive has been validated, you can 

<a name="gluster-restore"></a>
Restoring a Backup to Gluster
-----------------------------
While not part of the migration activities, should you need to restore your Gluster backup to a Gluster service, the tools provided will support this activity.

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

<a name="remove-gluster"></a>
Removing Gluster and Gluster Data
---------------------------------
Do not execute any of these steps if you are performing a practice migration.

Modify your `config.yaml` to remove `gluster` from the DataRobot configuration.

```yaml
# config.yaml snippet
servers:
  - services:
    - gluster
...
```

At this time it would also be prudent to make sure that `FILE_STORAGE_TYPE` is either absent or set to `s3`.

**NOTE**: It is also acceptable for this variable to be absent from the `config.yaml`.

```yaml
# config.yaml snippet
app_configuration:
  drenv_override:
    FILE_STORAGE_TYPE: s3
    ...
```

Do *not* perform any datarobot activites at this time.

Stop and remove the `gluster`` containers on each Gluster host with the following commands:

```bash
docker rm -f gluster
```

If you do not have enough storage to support an active Gluster installation, a Gluster backup, and a MinIO restore, you can remove Gluster data files at this time. If you have enough storage you might consider executing this step at a future point in time to recover disk space but after you've confirmed your migraiton has been successful.

Remove the Gluster storage, typically located in `/opt/datarobot/data/gluster`; a privileged user (someone who can become root) can remove the entire directory with the following command:

```bash
mkdir -p /opt/datarobot/gluster-tmp
rsync --archive --delete /opt/datarobot/gluster-tmp /opt/datarobot/data/gluster
rm -rf /opt/datarobot/data/gluster /opt/datarobot/gluster-tmp
```

<a name="minio-restore"></a>
Restoring a Gluster Backup to MinIO
---------------------------------
Restoring to MinIO should occur on an instance with MinIO already running on it. `docker ps | grep minio` should return a running minio docker container. You only need to perform a restore against a single `minio` service as MinIO will handle replicating the data to all available nodes. Any `minio` instance is acceptable for the restore process.

**NOTE**: Restoring up a large dataset can take a significant amount of time, so it is recommended that a terminal multiplexer (e.g. `tmux` or `screen`) are used to manage this restore. This will prevent accidental disconnection from interrupting a restore and allow you to check the status of the restore.

`datarobot-manage-gluster` has been provided as a tool to manage Gluster restores to MinIO.

To display all of the configuration options available, run:

```bash
/opt/datarobot/bin/datarobot-manage-gluster --help
```

The following command will initiate a restore to MinIO from an archive created on January 1, 2019, without compression, and stored in the `/opt/datarobot/data/backups/gluster` directory:

```bash
/opt/datarobot/bin/datarobot-manage-gluster \
    -b /opt/datarobot/data/backups/gluster \
    -f datarobot-gluster-backup-2019-01-01.tar \
    -n restore-s3
```

**NOTE**: If the backup was created today you can omit the `-f filename` from the proceeding command.

The restore will produce a line of output to the terminal for each file restored, and at the end of the restore will list both the total number of files restored and the number of files in the archive to compare and confirm.

You can remove Gluster data files and the backup archive at this time. If you have enough storage you might consider executing this step at a future point in time to recover disk space but after you've confirmed your migration has been successful.

Remove the Gluster storage, typically located in `/opt/datarobot/data/gluster`; a privileged user (someone who can become root) can remove the entire directory with the following command:

```bash
mkdir -p /opt/datarobot/gluster-tmp
rsync --archive --delete /opt/datarobot/gluster-tmp /opt/datarobot/data/gluster
rm -rf /opt/datarobot/data/gluster /opt/datarobot/gluster-tmp
```

Remove the Gluster backup archive:

```bash
rm -rf /opt/datarobot/data/backups/gluster
```


<a name="return-to-service"></a>
Return DataRobot to Service
---------------------------
Start by shutting down all of the `minio` nodes on all of the hosts running MinIO in the cluster.

```bash
docker stop minio
```

On the installation node, start the datarobot services:

```bash
bin/datarobot setup-dependencies
bin/datarobot run-registry
bin/datarobot install --skip-copy-code
```

You can now perform your normal testing to validate the health of the DataRobot installation.

<a name="logging-into-minio"></a>
Logging In to MinIO
-------------------
If it should become necessary to log into MinIO you can access it with a web browser at `https://hostname_or_IP:9000`.

**NOTE**: The SSL certificates are self-signed and stored on each DataRobot node, as such a desktop browser will not be able to verify the certificate.

The MINIO_ACCESS_KEY and MINIO_SECRET_KEY required for logging into the MinIO UI are stored in the DataRobot secrets repository.  To obtain these keys you can execute the following commands on a system running a MinIO container:

```bash
docker exec -it minio bash
python2 -m config.render -g minio -T "{{minio_env | shexports}}"
```

This will produce a set of shell variables, including the MINIO_ACCESS_KEY and the MINIO_SECRET_KEY.
