# Secrets Backup

DataRobot encrypts sensitive data at rest and, by default, secures backend services with passwords.  When a DataRobot Cluster is backed up you must also back up the secrets used to secure the DataRobot environment.  These secrets must be backed up at the same time as the databases.

If these files and directories are not backed up and restored as part of the DataRobot cluster you will lose access to data and analytics stored in the DataRobot environment.

* `.secrets-key`
* `certs/`
* `secrets.yaml`
* `secrets/`

These secrets cannot be recovered by DataRobot and it is critical that they are secured as part of your data management policy.
