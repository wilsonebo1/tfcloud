# VPC Installation

## AWS
### File storage configuration changes

`FILE_STORAGE_TYPE`: For Cloudera installations set to hdfs (WebHDFS storage driver) or hdfs3 (native HDFS storage driver). For Dockerized installations, set to gluster_api (Dockerized Gluster storage) or s3 (AWS S3 storage).

`FILE_STORAGE_PREFIX`: Represents the prefix applied to all paths in the file storage medium after the root path.

`config.yaml` snippet:

```yaml
---
app_configuration:
  drenv_override:
    FILE_STORAGE_PREFIX: /prefix/staging/
    FILE_STORAGE_TYPE: s3
```

Set these keys if you need to use AWS keys to access S3-based file storage. IAM role-based storage access is not yet available. Environment variables: 

`AWS_ACCESS_KEY_ID` : Access key ID for the account you want to use to connect to S3 storage.
`AWS_SECRET_ACCESS_KEY` : Secret access key for authenticating your AWS account.
`S3_BUCKET` : Name of the S3 bucket to store DataRobot application files in. Your access key ID must belong to an account that has write, read, and list permissions on this bucket.
Use `S3_HOST` and `S3_REGION` variables if you want to explicitly
specify which region you run on. 



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
                "arn:aws:s3:::vpc_installation/prefix/staging/*"
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

### Instance size recommendation (10Gb specific)

For details, refer to the "Memory Optimized" tab on [AWS EC2 Instances](h​ttps://aws.amazon.com/ec2/instance-types)

For modeling services it is recommended to use `r4.2xlarge` AWS instances (61 Gb RAM).
The general formula to compute per-worker RAM size is six times the on-disk dataset size. DataRobot does not use extensive on-disk caching for the modeling service, so 100Gb is a good default. 
