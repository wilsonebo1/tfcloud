# DataRobot Backup and Restore Guide

Welcome to the DataRobot Backup and Restore Guide.

This manual provides guidance regarding how to backup and restore a typical DataRobot installation. If your configuration is not typical additional steps may be required. You should consult with the DataRobot Customer Success team to confirm that these steps will produce a successful backup and restore strategy for your environment.

Once the various DataRobot application components are backed up the backups should be safeguarded using your company's data management policies and procedures. These backups do not guarantee a recoverable solution unless they are adequately protected and secured. Data management solutions designed for long-term storage (such as backup to tape or electronic vault solutions) are beyond the scope of this document.

**NOTE**: Unless otherwise specified, all commands in this document should be run as the non-privileged user (e.g. `user` from `config.yaml`).

**NOTE**: These instructions are all designed to work with `secrets_enforced` set to `true` or `false`.

**NOTE**: Instructions for both Docker-based and RPM-based installations have been provided where necessary.

<img src="images/datarobot-robot.png" alt="datarobot-logo"/>
