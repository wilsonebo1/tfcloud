# Exported Model File Validation

Exported DataRobot models contain [pickle] files, which exposes DataRobot to
the risk of executing erroneous or maliciously constructed code.

[pickle]: https://docs.python.org/2/library/pickle.html

When Exported Model File Validation is enabled, DataRobot will digitally sign
models at export time and verify these signatures at import time, thus
preventing execution of externally modified code.

## Enabling Exported Model File Validation

To enable signing and validation of model files, simply add the following
settings to your `config.yaml`.

```yaml
os_configuration:
  code_signing:
    enabled: true
    key_file_name: datarobot_codesigning.key
    cert_file_name: datarobot_codesigning_cert.pem
    ca_file_name: trusted_certificates.pem
    crl_file_name: revoked_certificates.pem
```

where

* `enabled` (false) - whether model signing is enabled. If this is not present
   or is false, none of the other options in this section are used.

* `key_file_name` - the name of the file with the key that is used to sign
  exported DataRobot models.

* `cert_file_name` - the name of the file used as the certificate to verify
  signatures made by the key.

* `ca_file_name` - the name of the file with trusted [CA] certificates, so
  DataRobot can verify model files whether they are trusted (no changes
  in the data and signature is trusted) or not.

  [CA]: https://en.wikipedia.org/wiki/Certificate_authority

* `crl_file_name` - specifies the path to a certificate which lists all revoked
  certificates, so that we won't trust keys that are compromised.

All mentioned file names are relative to `code-signing` directory of the
install directory.

Please note, it's required to enable `secrets_enforced` because both key and
certificates are stored as DataRobot secrets (see [Database Password Protection]
for details).

[Database Password Protection]: database-passwords.html

```yaml
os_configuration:
  secrets_enforced: true
```

## Disabling Exported Model File Validation

To disable signing and validation of DataRobot models:

* Update your `config.yaml`:

```yaml
os_configuration:
  code_signing:
    enabled: false
```

* Remove the file `/opt/datarobot/DataRobot-5.3.x/secrets.yaml` if it exists.

* Execute `./bin/datarobot install`

* If your cluster is integrated with Hadoop, you will need to run
  `./bin/datarobot hadoop-sync`.
