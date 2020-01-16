# Database Password Protection

DataRobot uses two databases for internal operations; Redis, and MongoDB.
Postgres may also be enabled for premium Model Monitoring functionality.

Password-enforced access to these databases may optionally be enabled using the following instructions.

## Enabling Password Protection

On each host in the cluster, as a user with `sudo` permissions, link the openssl.cnf distributed with DataRobot to /etc/ssl/openssl.cnf:
```bash
sudo ln -s /opt/tmp/release/venv/etc/ssl/openssl.cnf /etc/ssl/openssl.cnf
```

### If passwordless ssh has been configured

Run the following command on the provisioner host as the user with `sudo` access on every node in the cluster:
```bash
bin/datarobot setup-dependencies
```

To enable password protection on databases, add the following settings to your `config.yaml`:
```yaml
---
os_configuration:
    secrets_enforced: true
```

*NOTE*: If doing an upgrade or re-install where password protection was used before,
make sure to copy over `secrets.yaml` into the installation directory (beside
`config.yaml`) before proceeding, to use pre-existing passwords!

Run the following command on the provisioner host as the `datarobot` user:
```bash
bin/datarobot --pre-configure
```

Go to a single `mongo` host and start it in local mode without authentication as the `datarobot` user:
```
cp /opt/datarobot/etc/defaults/datarobot /opt/datarobot/etc/defaults/original_datarobot
sed -i 's/\(.*EXTRA_MONGO_OPTION.*\)/# \1/' /opt/datarobot/etc/defaults/datarobot
source release/profile
/opt/datarobot/app/DataRobot/bin/datarobot-mongo &
```

Record the mongo password created by the DataRobot installer:
```bash
grep mongo_password secrets.yaml | cut -f2 -d'"'
```

On that same host, as the `datarobot` user connect to mongo, create the mongo datarobot user, and set the password recorded in the previous step:
```bash
source release/profile
mongo localhost:27017/admin
rs.initiate()
use admin

# make sure the datarobot user does not yet exist
db.system.users.findOne({"user": "datarobot"})
# should return null

# if the datarobot user exists you should drop that user
# db.dropUser("datarobot")

# create a new datarobot user using the generated password
db.createUser({"user": "datarobot", "pwd": "<password-from-secrets.yaml>", "roles": [ "root" ]})
```

Shut down the mongo database by bringing the process to the foreground and typing Ctrl-C:
```bash
fg
^C
```

Re-enable Mongo Authentication and ensure that `EXTRA_MONGO_OPTIONS` is set:
```bash
sed -i 's/.*\(EXTRA_MONGO_OPTION.*\)/export \1/' /opt/datarobot/etc/defaults/datarobot
grep EXTRA_MONGO /opt/datarobot/etc/defaults/datarobot
# should return "export EXTRA_MONGO_OPTIONS=' --auth'"
```

From the provisioner, as a user with `sudo` access, start the DataRobot Platform services:
```bash
bin/datarobot services start
```

From the provisioner, as the `datarobot` user, finish the install process:
```bash
bin/datarobot install --post-configure
```

From the provisioner, as a user with `sudo` access, restart the DataRobot Platform services:
```bash
bin/datarobot services restart
```

Verify that mongo is healthy by running the following command on a host with the `availabilitymonitor` service defined:
```bash
curl localhost:9090/v1/health/?service=mongo
# look for '"healthy": true,' in the output
```

### If passwordless ssh has not been configured

Run the following command on each host in the cluster as a user who has `sudo` access on that host:
```bash
bin/datarobot setup-dependencies --limit-hosts <host IP>
```

To enable password protection on databases, add the following settings to your `config.yaml`:
```yaml
---
os_configuration:
    secrets_enforced: true
```

*NOTE*: If doing an upgrade or re-install where password protection was used before,
make sure to copy over `secrets.yaml` into the installation directory (beside
`config.yaml`) before proceeding, to use pre-existing passwords!

Run the following command on a single host in the cluster as the `datarobot` user:
```bash
bin/datarobot --pre-configure --limit-hosts <host IP>
```

As the `datarobot` user, copy `secrets.yaml`, `.secret-key`, and the `secrets\` directory and all of its contents to all the other hosts in the cluster:
```bash
scp -Cp secrets.yaml <host>:/opt/tmp
scp -Cp .secret-key <host>:/opt/tmp
scp -rCp secrets <host>:/opt/tmp
```

As the `datarobot` user, run the following command on each host in the cluster where you have not yet run this command:
```bash
bin/datarobot --pre-configure --limit-hosts <host IP>
```

Go to a single `mongo` host and start it in local mode without authentication as the `datarobot` user:
```
cp /opt/datarobot/etc/defaults/datarobot /opt/datarobot/etc/defaults/original_datarobot
sed -i 's/\(.*EXTRA_MONGO_OPTION.*\)/# \1/' /opt/datarobot/etc/defaults/datarobot
source release/profile
/opt/datarobot/app/DataRobot/bin/datarobot-mongo &
```

Record the mongo password created by the DataRobot installer:
```bash
grep mongo_password secrets.yaml | cut -f2 -d'"'
```

On that same host, as the `datarobot` user connect to mongo, create the mongo datarobot user, and set the password recorded in the previous step:
```bash
source release/profile
mongo localhost:27017/admin
rs.initiate()
use admin

# make sure the datarobot user does not yet exist
db.system.users.findOne({"user": "datarobot"})
# should return null

# if the datarobot user exists you should drop that user
# db.dropUser("datarobot")

# create a new datarobot user using the generated password
db.createUser({"user": "datarobot", "pwd": "<password-from-secrets.yaml>", "roles": [ "root" ]})
```

Shut down the mongo database by bringing the process to the foreground and typing Ctrl-C:
```bash
fg
^C
```

Re-enable Mongo Authentication and ensure that `EXTRA_MONGO_OPTIONS` is set:
```bash
sed -i 's/.*\(EXTRA_MONGO_OPTION.*\)/export \1/' /opt/datarobot/etc/defaults/datarobot
grep EXTRA_MONGO /opt/datarobot/etc/defaults/datarobot
# should return "export EXTRA_MONGO_OPTIONS=' --auth'"
```

On each host in the cluster, start the DataRobot services as a user with `sudo` access:
```bash
bin/datarobot services start --limit-hosts <host IP>
```

On each host in the cluster, finish the DataRobot install steps as the `datarobot` user:
```bash
bin/datarobot --post-configure --limit-hosts <host IP>
```

On each host in the cluster, restart the DataRobot services as a user with `sudo` access:
```bash
bin/datarobot services restart --limit-hosts <host IP>
```

Verify that mongo is healthy by running the following command on a host with the `availabilitymonitor` service defined:
```bash
curl localhost:9090/v1/health/?service=mongo
# look for '"healthy": true,' in the output
```
