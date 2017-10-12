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

* Run either of the following `make` commands:

```bash
make rotate-secrets  # Generate a new random password
make update-secrets  # Set a user-input password
```

If your cluster is integrated with Hadoop, you will then need to run `make push-configuration-to-hadoop` afterwards.

## Disabling Password Protection

To disable password protection:

* update your `config.yaml`:

```yaml
---
os_configuration:
    secrets_enforced: false
```

* Remove the file `/opt/DataRobot-4.0.x/secrets.yaml` if it exists.

* Execute `make recreate-containers`

* If your cluster is integrated with Hadoop, you will need to run
`make push-configuration-to-hadoop`.
