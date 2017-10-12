# Database Password Protection

DataRobot uses two databases for internal operations, Redis, and MongoDB.

Password-enforced access to these databases may optionally be enabled using the following instructions.

## Enabling Password Protection

### Before Installation

To enable password protection on both MongoDB and Redis, simply add the following settings to your `config.yaml`.

```yaml
---
os_configuration:
    secrets_enforced: true
```

### After Installation

To enable or change passwords after installing DataRobot, follow these steps.

* Make the above modification to your `config.yaml` file (set `secrets_enforced` to `true`).

* Enable secrets with

```bash
./bin/datarobot install
```

* You should regularly rotate secrets:

```bash
./bin/datarobot rotate-secrets
```

If your cluster is integrated with Hadoop, you will then need to run `./bin/datarobot hadoop-sync` afterwards.

## Disabling Password Protection

To disable password protection:

* update your `config.yaml`:

```yaml
---
os_configuration:
    secrets_enforced: false
```

* Remove the file `/opt/DataRobot-4.0.x/secrets.yaml` if it exists.

* Execute `./bin/datarobot install`

* If your cluster is integrated with Hadoop, you will need to run
`./bin/datarobot hadoop-sync`.
