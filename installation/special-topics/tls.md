# TLS Configuration {#tls-config}

## DataRobot Application TLS

If you are configuring DataRobot with TLS enabled, copy the TLS certificate and key files into the directory `/opt/datarobot/DataRobot-7.x.x/certs/` and update your `config.yaml` with the file names (paths are relative to the certs directory).
You may use separate keys for your prediction servers.

```yaml
    # config.yaml snippet
    ---
    os_configuration:
      webserver_hostname: something.example.com
      ssl:
        enabled: true
        cert_file_name: cert.pem
        key_file_name: cert.key
      prediction_endpoint: somthing-pred.example.com
      prediction_ssl:
        enabled: true
        cert_file_name: pred_cert.pem
        key_file_name: pred_cert.key
```

If your certificates are signed by an internal Certificate Authority, you will need to disable TLS certificate validation in the application.
```yaml
    # config.yaml snippet
    ---
    app_configuration:
      drenv_override:
        ALLOW_SELF_SIGNED_CERTS: true
        VERIFY_SSL: false
```
This will not disable SSL/TLS; all traffic to the web server will still be encrypted.

DataRobot supports TLSv1.2 and TLSv1.3 ciphers.  The default ciphers used by DataRobot web services can be overridden using the `os_configuration.ssl.ciphers`  parameter in `config.yaml`:

```yaml
# config.yaml snippet
---
os_configuration:
  ssl:
    ciphers: ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
```

[This Mozilla article](https://wiki.mozilla.org/Security/Server_Side_TLS) provides examples of strong cipher sets that could be configured for use in DataRobot.
