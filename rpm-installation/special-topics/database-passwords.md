# Database Password Protection

DataRobot uses a number of persistent services (such as databases) for internal operations.
Each of these services supports password-based authentication, which is recommended.

All installations include `mongo`, `rabbit`, and `redis`.
Additionally, `minio` may be used for a storage backend, and `postgres` and `elasticsearch` may be enabled for premium features.

## Enabling Password Protection

By default, password authentication is disabled for persistent services / databases.

*NOTE*: If doing an upgrade or re-install where password protection was used before, it is _critical_ to copy over `secrets.yaml`, `.secrets.key`, and the `secrets` directory from the previous installation directory into the new installation directory (beside `config.yaml`) before proceeding, to use pre-existing passwords!

### Password Protection

Enabling password protection is recommended. For installations using `minio`, this is required.

Enabling password protection on databases can be accomplished by adding the following settings to your `config.yaml`.

```yaml
---
os_configuration:
  secrets_enforced: true
```

Then proceed with (re-)installation.

### Disabling Password Protection

If password protection must be disabled for some reason, and `minio` is not being used, it can be disabled.

On the hosts from which you are running installation commands:

* Remove the line for `secrets_enforced: true` from `config.yaml`
* Remove the file `/opt/datarobot/DataRobot-6.x.x/secrets.yaml` if it exists (do not remove `secrets` dir or `.secrets.key`)

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
