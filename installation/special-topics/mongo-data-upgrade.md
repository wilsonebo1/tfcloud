# Mongo Data Upgrade

DataRobot version 4.2 upgraded the version of mongo shipped with our application from version 2.4 to 3.4.
As part of this upgrade, the backend mongo storage engine was changed from MMAPv1 to WiredTiger.

Customers upgrading from a prior release will need to upgrade their data to be compatible with mongo 3.4 and utilize WiredTiger storage.
The DataRobot installer includes a tool to automate the mongo data upgrade process.

## Upgrade overview

In broad strokes, the upgrade tool performs the following steps:

1. Moves the mongo data folder to a temporary working location on all mongo nodes 
2. Creates a fresh mongo 3.4 cluster using the existing configuration (secrets enabled, number and location of mongo hosts)
3. Performs sequential mongo upgrades through all necessary mongo versions (2.6 => 3.0 => 3.2 => 3.4) using a temporary mongo container configured as a standalone mongo service
4. Exports the mongo data from the temporary 3.4 standalone mongo service
5. Imports the mongo data into the permanent 3.4 cluster configured in step 2 (enabling WiredTiger storage for the data)

## Before running the upgrade tool

Before performing the mongo data upgrade, it is important that a data backup is available to use for mongo restoration in the event something goes wrong with the process.
The upgrade tool does not automatically take a backup of the data, and modifies the data in-place.
Therefore if no backup is available and something goes wrong during the upgrade, no rollback will be available.

The upgrade tool will prompt to confirm a backup has been taken before beginning the process.

## Using the upgrade tool

The mongo upgrade tool is run as part of the normal DataRobot upgrade process. 

The mongo upgrade command should be run after `./bin/datarobot setup-dependencies` and `./bin/datarobot run-registry` but before `./bin/datarobot install`.
A pre-flight check will confirm existing data has been upgraded.

Running the upgrade tool is done by issuing the following command:

```bash
./bin/datarobot upgrade-mongo
```

Before the upgrade begins, you will be prompted to confirm a mongo backup is in place.
You can bypass this verification by passing the `--skip-backup-check` flag.

### A note about existing replicasets
 
For customers already utilizing a clustered mongo configuration, it is important to verify all nodes are up to date with replication before beginning the mongo data upgrade.

The data upgrade is performed on only one of the existing mongo nodes, determined by whichever node becomes the mongo master after the new cluster is configured.

Therefore, if the nodes are not fully synchronized and the new master comes up on a node that was behind, the most recent data will be lost.

The current state of replication can be determined by connecting to the existing mongo cluster via mongo shell and examining the opttimeDate attribute for all members in the output of `rs.status()`:

```bin
rs0:PRIMARY> rs.status()['members'].forEach(function(member){ print(member.name + ' optimeDate: ' + member.opttimeDate) })
10.50.181.41:27017 optimeDate: Mon Feb 12 2018 23:21:12 GMT+0000 (UTC)
10.50.181.45:27017 optimeDate: Mon Feb 12 2018 23:21:12 GMT+0000 (UTC)
10.50.183.33:27017 optimeDate: Mon Feb 12 2018 23:21:12 GMT+0000 (UTC)
```

The opttimeDate should be identical for all members of the cluster.
If this value does not match, the mongo logs will need to be examined to determine why the nodes are out of sync.

### Upgrade tool runtime

The time taken to upgrade the data will depend entirely on the size of the mongo database and the speed of the systems running mongo.
On a standalone mongo service running on an AWS m4.2xlarge (8 vCPU, 32 GB memory) the upgrade process took around 1 hour per 100 GB of data on disk.

The sequential upgrades through 2.6 => 3.4 occur very fast on even large database sizes.
The export/import process required to enable WiredTiger consumes the bulk of the upgrade time; faster disk access will improve this time, as the entirety of the data is written to disk twice.

Configurations with clustered mongo should expect a longer time, as the data must replicate to multiple mongo nodes during the restoration.
Available network speeds will govern how much time this process adds. 

### Space constraints

The size on disk of the mongo files post-upgrade to WiredTiger will be greatly reduced compared to the size on disk pre-upgrade.

However, during the upgrade process the temporary working copy (the original files), the data export, and the imported database will all briefly co-exist.

All data will be confined to sub-directories within the `<DataRobot Home Dir>/data` directory.
Care should be taken to ensure the volume hosting this directory has sufficient free space of at least 2x the space consumed by the mongo files on disk.
