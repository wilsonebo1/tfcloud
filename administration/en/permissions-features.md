<a name="permissions-features-ref"></a>
Permissions and Features for User Accounts
==========================================
This reference lists the available permissions and settings the Admin can enable or disable for users. Permissions enabled for a user will only be visible to the Admin or to users with the "Can manage users" Admin Setting.

### Admin Settings

These are administrative-type permissions you can grant to users so they may manage, monitor, and troubleshoot DataRobot operations.

**NOTE:** Make sure you carefully control how you provide "Admin Settings" to non-Admin users. One way to do this is to add settings only on an as-needed basis and then remove those settings when related tasks are completed.

Setting   | Description   |
--------- | ------------- |
**Can create impersonated Data Store** | Ability to create and modify JDBC Data Stores that utilize impersonation
**Can delete/restore projects** | Ability to delete and/or restore projects for any users. Users without this permission can "deactivate" a project but not remove it from the system. Likewise, only users with this permission can restore a deactivated project.
**Can manage JDBC database drivers** | Ability to upload, modify, and delete database drivers related to DataRobot database connectivity.
**Can manage users** | Ability to access system-wide user Admin tasks such as editing user permissions, creating new users, creating organizations, etc. (Provides access to user management from the Account Settings dropdown.) Users cannot turn this off for themselves.
**Disable Database Connectivity** | Disables access to the database connectivity feature. By default, a user can view but not modify  existing drivers. Users can create and use data sources and data stores but only the owner can use, update, or delete the entry.
**Enable Activity Monitoring** | Ability to access the User Activity Monitor
**Enable Admin Api Access** | Ability to access to the administrative API
**Enable Resource Monitor** | Ability to access the Resource Monitor
**Enable SAML SSO configuration management** | Ability to configure SSO through the UI (SAML SSO must be enabled through cluster configuration)

### Optional Features

You can select to enable or disable these features on a user-by-user basis. The settings shown here may be expected for a typical cluster configuration:

Feature   | Description   |
--------- | ------------- |
**Disable Fast EDA** | Disables support for Fast EDA during ingest (this feature is enabled by default)
**Disable Jupyter IDE** | Disables access to Jupyter Notebook (this feature is enabled by default)
**Disable Model Management** | Disables Model Management functionality
**Don't include Eureqa models in Autopilot** | Removes Eureqa models from Autopilot. (They will still be available in the Repository when supported.)
**Enable Additional Eureqa Blueprints** | Enables ability to access to `Eureqa Classifier` and `Eureqa Regressor` blueprints (in addition to the default `Eureqa GAM` blueprint)
(\*) **Enable Anomaly Detection** | Enables access to anomaly detection models and insights
**Enable Predictions Admin** | Enables ability to deploy models and configure their weight
**Enable using the original datetime format** | Enables ability to use (original) datetime format from the uploaded prediction dataset to generate an additional “original” timestamp column in downloaded predictions

(\*) denotes features recommended for all users

And, this table shows additional **Optional Features** you may see, depending on cluster configuration.

Feature   | Description   |
--------- | ------------- |
**Enable HDFS ETL** | Enables support for 100GB ingest through Hadoop Distributed File System (HDFS)
**Enable Hadoop Deployment** | Enables scoring on Hadoop from the leaderboard; applies to Hadoop deployments only
**Enable multi-job forecast distance modeling** | Enables splitting Feature Impact computation into multiple queue jobs; the feature impact jobs can be split and run on multiple workers
