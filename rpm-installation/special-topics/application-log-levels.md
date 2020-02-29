# Modifying Application Log Levels

DataRobot log levels are configured using the `app_configuration.drenv_override.LOGGING_LEVELNAME` and `app_configuration.drenv_override.LOG_LEVEL` keys in the `config.yaml` file.

By default, DataRobot logs all messages at `INFO` level or above. If you would like to reduce the number of application messages that are recorded by the system consider changing `LOGGING_LEVELNAME` and `LOG_LEVEL` to `WARNING` or `ERROR`.  Acceptable parameters are `DEBUG`, `INFO`, `WARNING`, `ERROR`, or `CRITICAL`.

**NOTE**: If you encounter application issues it is likely that DataRobot Customer Support will ask you to provide `INFO`-level logs for troubleshooting purposes.  Raising the log level to WARN or above may result in inadequate logs for issue resolution in some cases.

**NOTE**: Changing `LOGGING_LEVELNAME` or `LOG_LEVEL` requires a restart of the DataRobot application.

To change the application log levels to `WARNING`, modify `config.yaml`:

```
# config.yaml configuration snippet:
[...]
app_configuration:
  [...]
  drenv_override:
    [...]
    LOG_LEVEL: WARNING
    LOGGING_LEVELNAME: WARNING
    [...]
  [...]
[...]
```

As the unprivileged user, usually defined as `user` in `config.yaml`, run the following command:
```bash
bin/datarobot install --pre-configure
```

As the user with privileged access, usually defined as `admin_user` in `config.yaml`, run the following command:
```bash
bin/datarobot services restart
```
