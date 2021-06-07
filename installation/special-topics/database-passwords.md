# Database Password Protection

DataRobot uses a number of persistent services (such as databases) for internal operations.
Each of these services supports password-based authentication, which is recommended.

All installations include `mongo`, `rabbit`, and `redis`.
Additionally, `minio` may be used for a storage backend, and `postgres` and `elasticsearch` may be enabled for premium features.

## Password Protection

By default, password authentication is enabled for persistent services / databases.

*NOTE*: If doing an upgrade or re-install where password protection was used before, it is _critical_ to copy over `secrets.yaml`, `.secrets.key`, and the `secrets` directory from the previous installation directory into the new installation directory (beside `config.yaml`) before proceeding, to use pre-existing passwords!

### Disabling Password Protection

Disabling password protection is not recommended. For installations using `minio`, this is not supported.

Otherwise, disabling password protection on databases can be accomplished by adding the following settings to your `config.yaml`, on the hosts from which you are running installation commands:

```yaml
---
os_configuration:
  secrets_enforced: false
```

On the hosts from which you are running installation commands:

* Remove the file `/opt/datarobot/DataRobot-7.x.x/secrets.yaml` if it exists
* Remove the files in `/opt/datarobot/DataRobot-7.x.x/secrets/*` if they exist (do not remove `secrets` dir or `.secrets.key`)

On each host:

* Remove the files in `/opt/datarobot/etc/secrets/*.json` if they exist (do not remove `.enc` files)

Then proceed with (re-)installation.

### Re-enabling Password Protection

If password protection is disabled for some reason, it can be re-enabled.

On the hosts from which you are running installation commands:

* Remove the line for `secrets_enforced: false` from `config.yaml`

On each host with `mongo`:

* Remove the file `/opt/datarobot/data/mongo/mongo.state.json` if it exists

Then proceed with (re-)installation.

### Secrets Rotation

The passwords used for authentication for databases can be rotated. 

First, run this command from the installation host to create the new secrets:

```bash
./bin/datarobot rotate-secrets
```

Then, restart the services to use the new secrets:

```bash
bin/datarobot services restart
```
