# TLS Configuration {#tls-config}

## DataRobot Application TLS

If you are configuring DataRobot with TLS enabled, copy the TLS certificate and key files into the directory `/opt/datarobot/DataRobot-4.5.x/certs/` and update your `config.yaml` with the file names (paths are relative to the certs directory).
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

## Hadoop Manager TLS {#cm-tls}

If your Hadoop Manager is secured with TLS, set the following flags in your `hadoop-configuration.yaml` file:

```yaml
    # hadoop-configuration.yaml snippet
    use_tls: true
    ignore_ca: true
```

`use_tls: true` will enable TLS connections to your manager server.

`ignore_ca: true` will ignore certificate validation errors in the event your server's TLS certificate is signed by a custom Certificate Authority.
