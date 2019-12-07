# Data ingestion from Google Cloud Storage

On Premise installations of DataRobot support ingestion of Google Cloud Storage objects using either of the two methods described below.

Once configured correctly Google Cloud Storage objects are accessible using links as `gs://<bucket-name>/<file-name.csv>`.


## Ingest From Google Cloud Storage Using A Service Account

The first option for data ingest from Google Cloud Storage uses the native storage protocols.

**Note**: The directions here are intended for when google storage is only used for data ingest.
If google storage is to be used for data ingest and backend storage, both features share the same service account configuration,
and the directions for configuring backend storage should be used instead.

There are several ways to configure DataRobot to access Google Cloud Storage depending on how credentials will be supplied.
Refer to the description with each subsection below to determine which is the best fit for a particular installation.

The following values are common and must be set for all methods of supplying credentials:

`ENABLE_GS_INGESTION` : Must be `True` to enable google storage ingest using native protocols.

`GOOGLE_STORAGE_CREDENTIALS_SOURCE` : Specifies how the credentials will be provided to DataRobot, see the examples below.

For the examples using a "keyfile", follow [these instructions](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#iam-service-account-keys-create-console)
to create and download a JSON key file for the appropriate service account.


### Configure the application running in GCE using the `config.yaml`

Google can provide ["Application Default Credentials (ADC)"](https://cloud.google.com/docs/authentication/production)
to software running on a GCE instance.
The GCE instance must be [configured with a default service account](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances)
in order for this to work.
This method is the most convenient and secure because google will manage all credentials outside the
instance, so plain-text credentials will not be stored.

Example `config.yaml` snippet:

```yaml
---
app_configuration:
  drenv_override:
    ENABLE_GS_INGESTION: True
    GOOGLE_STORAGE_CREDENTIALS_SOURCE: adc
```

`ENABLE_GS_INGESTION` : Must be `True` to enable google storage ingest using native protocols.

`GOOGLE_STORAGE_CREDENTIALS_SOURCE` : Must be `adc` to select Application Default Credentials.


### Configure the application with base64 encoded credentials using the `config.yaml`

To avoid having to manually copy the keyfile to all nodes in the cluster, the base64-encoded contents
can be set in the configuration and DataRobot will create temporary files where needed.

Example `config.yaml` snippet:

```yaml
---
app_configuration:
  drenv_override:
    ENABLE_GS_INGESTION: True
    GOOGLE_STORAGE_CREDENTIALS_SOURCE: contents
    GOOGLE_STORAGE_KEYFILE_CONTENTS: |
        CnsKICAidHlwZSI6ICJzZXJ2aWNlX2FjY291bnQiLAogICJwcm9qZWN0X2lkIjogInBpdm90YWwt
        cHVycG9zZS0yNTUyMTIiLAogICJwcml2YXRlX2tleV9pZCI6ICJlYzE2MzBmOWZjNDA1NjJmZDRl
        ODNmYjZjOWY1YzQ4MzVlOTdlMGJiIiwKICAicHJpdmF0ZV9rZXkiOiAiLS0tLS1CRUdJTiBQUklW
        QVRFIEtFWS0tLS0tXG5NSUlFdmdJQkFEQU5CZ2txaGtpRzl3MEJBUUVGQUFTQ0JLZ3dnZ1NrQWdF
        QUFvSUJBUURkWXduWm9sdnltK2xXXG5OSVBORWxLZzhFUFJzV0Y5ek9RZnhUdzFqeElxTlRtNHpN
        QXY1WWk0VVZPN1RLZ3R5SFRITVQ3am02WThXKzhpXG5LZTVLUWxWYmR5U0lhNjM5ci8wQ3U5Q0lU
        NGVlWTFpbHhvVmJwRVE5bzdCbFJta0d3TWlUWVZVZDBsa3NVenlyXG5NNzNZMjJtdDRRUkp1Tk9O
        aUZMYkR4VHRkT0FENFdiVjRVTzN0UHZ5cmI5cFpoYUE5WWh6VG45RTE2UFYvdWdIXG4vZmRZRndS
        RWtkQWl6S3FRbE1hZk1qWGpSbHZhWWdIUlVUdmw1NGFZVXRyTmR2MEgzYVpLNHNVTVdYekt2Z1lv
        XG5EMS9yaWRXaURxckR6eit0aWxUZ0hZQkhUbW5rc3pzVlI2UjhwSW1jVFBRY3R6Sk1oQm4rbHJ3
        WjhIQ2Q2MG9XXG5BcGdGakVCQkFnTUJBQUVDZ2dFQUNoOVBvWHhMY1BYUS91aUt5RE1ZeFJRSFBj
        eTY5T29MMmlvRi9UcnI3VE1lXG56d1RKbXNjSGI4b0VKcEcwTk5ld0F6V010eEowVU5reFAySWth
        NC9KNEZNN3YrTVFnd05yY1pjTnkxVzdrVEhnXG5xVC9BOURZNENvdHo4c1Y3NHR1b3NCaG9zR0xn
        UWVjU1pJK0tsQ0pBSER1b0d3alEzMjFHd0k1WmVodjRiQ1RwXG42S1pDRi9jenhKcXNIc0IxOWFX
        MXdrajE0YlZ3MXJJZWkydmUzZlNKY0NDU2FTazFtN3VLWnZ6V3VGRUhmSnl2XG5DbDgrUVR3WVFr
        Y3BxOFBKeTJsUWZIRVhZWE9NZ09pWFk2YThRMklrakpEOU1wMVcxYVYyai9TQ0Nvb0N6R05NXG5h
        cnJXWHJOQys3WUMwaTFZeDNoai90ZEdnTFg2NmZkOGJyZm1SWlovRXdLQmdRRDQzcWlmUGFQQkJX
        eUthZ3JoXG5GblJLZ3piUFVBM3UyTXlJSmxTZWtpeGJpWTEzQ0J4emh2dGRscHJ6aE4ydm9odlRR
        U3lBTndyaG1nK0ZTSmtHXG5aUDJMeE0wRDlqNnRLdTUvbFlLTFFpUkkyY3dyKzBsM08wRmQ2RDdG
        Y2t0SnBnRmFYMk4wQkRTTU1BaVF3ejhpXG5FYWhFcjNmQ3Z5RzdDMDl3VTh2NWhwU1lId0tCZ1FE
        anVzNU00NDFDU21HODRwbmwveSsvTXN3RnJIdnFpenVVXG5yUFRqTzNBZFZTTWt0c09neEF0SDdR
        U2pjenUxaFJ0SUQxOG9rYjM1ZjFEM0NVcXIvbEoyNWM1WThKc013VlhDXG5HVGwvaEg5bU1QOVNo
        U2ZQbjhDdVpsOGl6TTVpaksvWUZGRGFBbENwdmw1bVV0Vm5GcFB4dlF6Vk43MFpjc3NsXG5la0Fh
        WC9tYm53S0JnQXk3ajVMK0cxZXZ5RnJZakEveUR5Y1V5WVFYeTI2eDV0ejhZUTN2MnBjZ1ZYMkdp
        N1laXG5iTmpmOExPTzA2eTl0WUM4YitOcmJZSVhXTDN2OWV4TzFHNEhOcG9DU2ppZjNxM21YMVJ5
        b05xZFVnWGFDR3N5XG5PK2pyRGZNYUl1SDB2Vkw3V0dKQ0tOSVhUd2poQkdUZzFHUVhPaUJibVFV
        eDBmR2tSK1pQVFdEdkFvR0JBTVFLXG44c0lhT21iUTVhYlhaQ2t0TDR0blRWK3RCdGY0bUlmN0JL
        NEJZeGk5VEEyMUVGLzdwTUo4ZGp2SFhhVjhPdW9qXG40WVZwUWFQaFNIQUNIYmhHcmZNUkRqeGVs
        UHU4Qy9tV0FYdVhNcDFrbk1nTFBTUnRvRkFDYk8vbVk5MU93Nm8rXG5nd1BLYm1wU0thM29yVEdi
        ckN5MDFMRlExSWR0M1JnY1Q4Ymt6RnA5QW9HQkFLZktDb3EyZmp4MVJXeW5vZmpYXG5zOVhtbVRE
        RU12T0xObHRMcEovN2JRdjJLOTM0MUVWbEZlc0JzVEFuVlVwZWJxMTkwaEVWSjRpV0tiOGN2WEg0
        XG5wVlZNNlY5akM3MWVSWVRrZndVRldzYldjQTVjSmhhZkgrUGQvYjJ5M0pqdjBSMm5BQUQyL3BT
        Rlk5Y1pGRE45XG5BUUpHQUduVVYrWWZaQmdOOG4vd2E0RXdcbi0tLS0tRU5EIFBSSVZBVEUgS0VZ
        LS0tLS1cbiIsCiAgImNsaWVudF9lbWFpbCI6ICJsb2NhbC1kYXRhcm9ib3RAcGl2b3RhbC1wdXJw
        b3NlLTI1NTIxMi5pYW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsCiAgImNsaWVudF9pZCI6ICIxMDk1
        OTc4MDc0NjQ4NzkwMDg5MzQiLAogICJhdXRoX3VyaSI6ICJodHRwczovL2FjY291bnRzLmdvb2ds
        ZS5jb20vby9vYXV0aDIvYXV0aCIsCiAgInRva2VuX3VyaSI6ICJodHRwczovL29hdXRoMi5nb29n
        bGVhcGlzLmNvbS90b2tlbiIsCiAgImF1dGhfcHJvdmlkZXJfeDUwOV9jZXJ0X3VybCI6ICJodHRw
        czovL3d3dy5nb29nbGVhcGlzLmNvbS9vYXV0aDIvdjEvY2VydHMiLAogICJjbGllbnRfeDUwOV9j
        ZXJ0X3VybCI6ICJodHRwczovL3d3dy5nb29nbGVhcGlzLmNvbS9yb2JvdC92MS9tZXRhZGF0YS94
        NTA5L2xvY2FsLWRhdGFyb2JvdCU0MHBpdm90YWwtcHVycG9zZS0yNTUyMTIuaWFtLmdzZXJ2aWNl
        YWNjb3VudC5jb20iCn0K
```

`ENABLE_GS_INGESTION` : Must be `True` to enable google storage ingest using native protocols.

`GOOGLE_STORAGE_CREDENTIALS_SOURCE` : Must be set to `contents`.

`GOOGLE_STORAGE_KEYFILE_CONTENTS` : set to the base64-encoded contents of the JSON keyfile


### Configure DataRobot with a manually distributed credentials file using `drenv_override`

The keyfile must be manually distributed to the same path on all nodes, and this path must be supplied in the configuration.

Example `config.yaml` snippet:

```yaml
app_configuration:
  drenv_override:
    ENABLE_GS_INGESTION: True
    GOOGLE_STORAGE_CREDENTIALS_SOURCE: path
    GOOGLE_STORAGE_KEYFILE_PATH: /opt/datarobot/etc/credentials/<keyfile.json>
 ```

`ENABLE_GS_INGESTION` : Must be `True` to enable google storage ingest using native protocols.

`GOOGLE_STORAGE_CREDENTIALS_SOURCE` : Must be `path` to select `GOOGLE_STORAGE_KEYFILE_PATH`.

`GOOGLE_STORAGE_KEYFILE_PATH` : Path to a google service account credentials file, must be present on all cluster nodes and containers (in `/opt/datarobot/etc/credentials/` is suggested).


## Ingest From Google Cloud Storage Using S3 Compatibility

The second configuration option for data ingest from Google Cloud Storage relies on Google Cloud Storage implementation of AWS S3 protocol, also known as Interoperability feature.

Follow [these directions](https://cloud.google.com/storage/docs/migrating#keys) to enable the interoperability feature and create an Access Key with a Secret.

Example `config.yaml` snippet:

```yaml
app_configuration:
  drenv_override:
    ENABLE_S3_INGESTION: True
    GOOGLE_STORAGE_KEY_ID: <Access Key>
    GOOGLE_STORAGE_SECRET: <Secret>
 ```

`ENABLE_S3_INGESTION` : Must be set to `True` to enable google storage ingest using S3 interoperability.
`GOOGLE_STORAGE_KEY_ID` : Access Key created in Google Cloud Console.  
`GOOGLE_STORAGE_SECRET` : Secret value for the above key.
