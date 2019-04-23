# Model Management Data Upgrade

Starting with DataRobot release 5.0, model monitoring and management is receiving vast performance 
and scaling improvements. As a consequence of this improvement, all historical data is no longer 
visible in existing deployments. _The data has not been removed, only archived._ Any deployment data
created on release 4.4.1 of DataRobot (or later) can be migrated into the new model monitoring and 
management storage tables. The DataRobot installation includes a tool to automatically perform this
data migration.

Additionally, as part of the improvement, the upgrade to DataRobot release 5.0 disables drift 
tracking for all existing deployments. **In order to continue tracking drift for existing 
deployments, you will need to re-enable drift tracking for each of them.** This step can be 
performed via the DataRobot UI or the `trackingSettings` endpoint of the API. 

## Upgrade Overview

The model monitoring data upgrade tool copies data from archived tables in the DataRobot PostgreSQL
database into new tables, which store the same information much more efficiently. The total size of
data on disk in these new tables is far smaller than in existing tables, and so performing the 
upgrade should not significantly increase overall size of the PostgreSQL database. A future release 
of DataRobot will include a tool to destroy data from the archived tables, greatly reducing the disk 
size requirements for PostgreSQL.  
 
* The tool is completely non-destructive -- it only populates new tables; it does not delete data from
any existing tables. 
* The data upgrade tool is fully idempotent -- it can be rerun multiple times without introducing data 
corruption. The tool can also cancelled and restarted at any point without risking data integrity. 
* The tool can be run at any point after DataRobot has been upgraded to release 5.0 (or later), and 
it should not cause application downtime or significantly affect performance of the running 
application. 
* It can upgrade all deployments in a DataRobot installation or only selected deployments.

## Using the upgrade tool
 
After DataRobot has been upgraded to release 5.0 (or later), options for running the tool can be 
viewed by issuing the following command:

```bash
/opt/datarobot/sbin/datarobot-migrate-modmon-data --help
```

For DataRobot installations containing fewer than one million predictions, DataRobot recommends 
simply migrating all deployments to the new schema using the following command:

```bash
/opt/datarobot/sbin/datarobot-migrate-modmon-data --verbose
```

For larger DataRobot installations, you may wish to migrate only selected deployments to new tables
in order to speed up overall migration runtime. To migrate selected deployments, run the following 
command (replacing the listed deployment IDs with those from your DataRobot installation):

```bash
/opt/datarobot/sbin/datarobot-migrate-modmon-data --verbose --deployment-ids 5c756bb09219fd13ad19fe18 5c756bb09219fd13ad19fe19
```

Deployment IDs can be retrieved from the URL of any page displaying information about the 
deployment. For instance, in the URL `https://app.datarobot.com/deployments/5bbb9a57b11ba426eba28c43/overview`, 
the deployment ID is `5bbb9a57b11ba426eba28c43`.

### Upgrade tool runtime

The time taken to upgrade data will depend entirely on the size of the PostgreSQL database and the 
specifications of the server hosting PostgreSQL. Number of deployments and number of predictions on 
each deployment directly correlate to upgrade runtime.

Expect the migration to take around one minute per 15k predictions migrated. This may vary depending
on your data.

### Purging archived data

Once all deployments have been migrated, data from the archived tables can be purged by executing 
the following command:

```bash
/opt/datarobot/sbin/datarobot-purge-modmon-data --purge-all
```

If it is desirable to keep newer archived data and purge older archived data, this script can be run 
with any `--purge-before` date and it will only purge archived data from before the specified date.
For example, all archived data prior to 2019 can be purged by executing the following command:

```bash
/opt/datarobot/sbin/datarobot-purge-modmon-data --purge-before 2019-01-01
```
