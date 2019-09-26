# Database Password Protection

DataRobot uses two databases for internal operations; Redis, and MongoDB.
Postgres may also be enabled for premium Model Monitoring functionality.

Password-enforced access to these databases may optionally be enabled using the following instructions.

## Enabling Password Protection

### Before Installation

To enable password protection on databases, simply add the following settings to your `config.yaml`.

```yaml
---
os_configuration:
    secrets_enforced: true
```

*NOTE*: If doing an upgrade or re-install where password protection was used before,
make sure to copy over `secrets.yaml` into the installation directory (beside
`config.yaml`) before proceeding, to use pre-existing passwords!

### After Installation

To enable or change passwords after installing DataRobot, follow these steps.

* Make the above modification to your `config.yaml` file (set `secrets_enforced` to `true`).

* Enable secrets with

{% block enable_secrets_command %}
```bash
./bin/datarobot install
```
{% endblock %}

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

* Remove the file `/opt/datarobot/DataRobot-5.2.x/secrets.yaml` if it exists.

* Execute:

{% block disable_secrets_command %}
```bash
./bin/datarobot install
```
{% endblock %}

* If your cluster is integrated with Hadoop, you will need to run
`./bin/datarobot hadoop-sync`.
