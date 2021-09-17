# Downloadable Portable Prediction Server

Portable Prediction Server (aka PPS) is a Docker image which reprsents a portable version of a Prediction Server.
The feature that makes it available via DataRobot UI in DeveloperTools is called "Downloadable PPS".
By default the feature is not enabled and users will see an error message in "Dev Tools" in the UI. 
PPS image is shipped in a private Docker registry (typically, on the `provisioner` node) along with "datarobot-runtime" image starting v5.3.
But shipping it in a private registry is not user-friendly, that is why this feature was implemented.
The sections below explain how it works and how to configure it. 

## How the feature works


Roughly speaking the feature makes sure that the image is uploaded from the Docker registry to the File Storage.
Namely:
- `imagesaver` service "docker pull"s the image to the node where the service is running
- `imagesaver` service re-tags the image (adds proper version, removes internal IP address from its name)
- `imagesaver` service streams the image bytes to the Admin API route in Public API controller
- `Public API` worker compresses the image contents and calculates image metadata on the fly, while pushing the compressed contents to the File Storage.
-  In the end `imagesaver` service updates image metadata in MongoDB
-  When user goes to Developer Tools page in UI, Public API either streams the compressed image data to the client or redirects to the File Storage (if the storage supports signed URLs and it is properly configured).

The whole process takes around 25-30 minutes. As a result ~14GB image is compressed to ~7GB.
During that 30 minutes a node with `imagesaver` heavily consumes CPU as well as exactly 1 worker on one of the Public API nodes stays busy. 
This process happens only once per installation: the same image will not be uploaded more than once after `imagesaver` is restarted.
After the image is uploaded the `imagesaver` service remains idle and consumes no resources. (It can even be stopped). Essentially, it is a one time job.

## Configuration

In order to make PPS image downloadable make sure that a single `imagesaver` service is present somewhere in the cluster layout on one of the nodes.
The exact node location is not very important per se as the service will remain idle after the first 30 minutes.

### Example

```yaml
# config.yaml snippet

# Service layout
servers:
# Application node (based on `multi-node-mlops.yaml` for example)
- services:
  ...
  - imagesaver
  ...
  hosts:
  - XXX.XXX.XXX.XXX
  app_configuration:
    drenv_override:
      # Optimisation: Do not import redundant 'datarobot-runtime' image.
      # The "Downloadable PPS" feature will work no matter what this value is.
      IMAGE_SAVER_UPLOAD_IMAGES_ENABLED: false
```
