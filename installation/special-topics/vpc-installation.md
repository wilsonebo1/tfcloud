# VPC Installation

## AWS
### File storage configuration changes

`FILE_STORAGE_TYPE`: For Cloudera installations set to `hdfs` (WebHDFS storage driver) or `hdfs3` (native HDFS storage driver).
For Dockerized installations, set to `gluster_api` (Dockerized Gluster storage) or `s3` (AWS S3 storage).

`FILE_STORAGE_PREFIX`: Represents the prefix applied to all paths in the file storage medium after the root path.

`config.yaml` snippet:

```yaml
---
app_configuration:
  drenv_override:
    FILE_STORAGE_PREFIX: /data/
    FILE_STORAGE_TYPE: gluster_api
```

If using `s3` storage type, you must addtionally set

`S3_BUCKET` : Name of the S3 bucket to store DataRobot application files in. Your access key ID must belong to an account that has write, read, and list permissions on this bucket.

You may addtionally set the `S3_HOST` and `S3_REGION` variables if you want to explicitly specify which region you run on, or if you are using a storage provider which provides an S3-compatible API.

DataRobot recommends using AWS IAM roles attached to your instances to authenticate with S3 storage.
If you prefer to use keys, or are connecting to an S3-compatible API, you will additionally need to add your credentials as environment variables:

`AWS_ACCESS_KEY_ID` : Access key ID for the account you want to use to connect to S3 storage.
`AWS_SECRET_ACCESS_KEY` : Secret access key for authenticating your AWS account.


### IAM role policy settings

Example of IAM role policy for S3 access.

Note: the resource path composed as concatenation of `S3_BUCKET` and `FILE_STORAGE_PREFIX` values.
In this example `S3_BUCKET=vpc_installation`:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessToProduction",
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject",
                "s3:Get*",
                "s3:PutObject",
                "s3:ReplicateDelete",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::vpc_installation/data/*"
            ]
        },
        {
            "Sid": "AllowListBucketsProduction",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:ListBucketVersions",
                "s3:ListAllMyBuckets"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
```

### Allowing unverified SSL
If there is a customer environment that needs to connect to their own object storage using unverified SSL, add this to the config.yaml:

```yaml
---
app_configuration:
  drenv_override:
    S3_VALIDATE_CERTS: False
    ALLOW_SELF_SIGNED_CERTS: True
```
