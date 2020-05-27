# Secrets Restore

DataRobot encrypts sensitive data at rest and, by default, secures backend services with passwords.  When a DataRobot Cluster is restored you must restore to an environment that was installed with the same secrets used to secure the DataRobot environment.

If these files and directories are not backed up and if they are not used when installing the DataRobot cluster you will lose access to data and analytics stored in the DataRobot environment.

* `.secrets-key`
* `certs/`
* `secrets.yaml`
* `secrets/`

These secrets cannot be recovered by DataRobot and it is critical that they are secured as part of your data management policy.
