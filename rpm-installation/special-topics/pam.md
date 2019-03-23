# Integration with PAM

DataRobot can optionally be integrated
with [Pluggable Authentication Module][1], so authentication policies
can be configured in unified way outside of DataRobot application.

Note: PAM authentication is only available for RPM-based installations.

[1]: https://en.wikipedia.org/wiki/Pluggable_authentication_module

## Workflow

When PAM authentication is enabled, we assume that user records are
managed outside of DataRobot application. This assumption has several
implications:

1. DataRobot user records are created on first successful login.
2. DataRobot users are not allowed to manage their passwords within
   DataRobot application.
2. DataRobot Administrators are not allowed to create users in admin
   panel.

## Configuration

### PAM

It is recommended to create a special PAM configuration file for
integration with DataRobot, e.g. `/etc/pam.d/datarobot`. We'll be
referring to the name of this file (`datarobot` in the example above)
as service name.

### DataRobot

- **`USER_AUTH_TYPE`** - `pam`
- **`USER_AUTH_PAM_SERVICE_NAME`** (optional) - name of PAM service to
  be used by DataRobot application (default: `login`)
- **`USER_AUTH_PAM_SKIP_CHECK`** (optional) - if set to `true`,
  DataRobot application won't try to verify whether password has
  expired or user is permitted access to the request service (default:
  `false`)

### `config.yaml`

To enable DataRobot PAM integration one needs to:

* Update `config.yaml`:

```yaml
---
app_configuration:
    drenv_override:
        USER_AUTH_TYPE: pam
        USER_AUTH_PAM_SERVICE_NAME: datarobot
```

* Execute `./bin/datarobot install`
