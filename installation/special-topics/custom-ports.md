# Custom ports for webserver

## Setting up global and per-server http ports configuration

Custom ports are configured using `os_configuration.*.http[s]_port`
key in `config.yaml` file.

Mainwebserver uses `os_configuration.webserver` section and dedicated predictions
use `os_configuration.dedicated_prediction`.

Example configuration snippet:

```
os_configuration:
  webserver:
     http_port: 18000
  dedicated_prediction:
     http_port: 18001
```
