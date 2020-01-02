# LRS operator configuration

LRS Operator - is the Kubernetes operator we implemented to run LongRunningServices in the Kubernetes.
LRS operator supports LongRunningServices which may contain a Custom Models.

## DataRobot configuration file

The DataRobot configuration file (`config.yaml`) must contain a `kubernetes` top-level
section with settings for a kubernetes cluster(s). Each cluster settings block might have an
`lrs-operator` section. This section must contain the following set of settings:

* `instance-name: dsp-lrs-operator`
This is a cluster-unique ID of the LRS operator to be used by the DataRobot application. Must contain lower-case letters only, must not contain underscores. This value must be identical to the value of “LONG_RUNNING_SERVICES_OPERATOR_INSTANCE_NAME” option in the DataRobot application configuration to allow correct communication between the application and the operator.
* `docker-image: "<docker-registry>.<cluster-dns-zone>/datarobot/operator-lrs"`
This docker image is used to run LRS operator containers in the kubernetes cluster. This docker registry service must be reachable from the kubernetes-worker networks and from the provisioner machine.
* `docker-image-tag: <lrs-operator-sha>`
Optional. This docker image tag is used to run LRS operator containers in the kubernetes cluster. When not specified, the docker image tag of the LRS operator docker image which is used in the LRS operator installation is used as default. The LRS operator docker image with this tag must be uploaded to the docker registry service beforehand.
* `docker-registry-username: <username>`
This username is used to authorize to the docker registry service and then fetch the LRS operator docker image to kubernetes worker nodes. Use any non-empty value when the docker registry is not password-protected.
* `docker-registry-password: <password>`
This username is used to authorize to the docker registry service and then fetch the LRS operator docker image to kubernetes worker nodes. Use an empty value (“”) when the docker registry is not password-protected.
* `ingress-annotation-prefix: nginx.dsp.ingress.kubernetes.io`
This option must be in sync with the k8s-installer extension used in kubernetes installation.
* When `automatedapps` extension was used, use `nginx.aapps.ingress.kubernetes.io`
* When `dataengine` extension was used, use `nginx.dataengine.ingress.kubernetes.io`
* When `datascience_platform` extension was used, use `nginx.dsp.ingress.kubernetes.io`
* `ingress-class: nginx-dsp`
This option must be in sync with the k8s-installer extension used in kubernetes installation.
* When `automatedapps` extension was used, use `nginx-aapps`
* When `dataengine` extension was used, use `nginx-dataengine`
* When `datascience_platform` extension was used, use `nginx-dsp`
* `ingress-tls-enable: true`
This option regulates if the HTTPS endpoints of LRS containers will have TLS termination.
The recommended value is `true`. This option may have one of two values only: `true` or `false`

After providing the correct configuration of the LRS operator, we may proceed to the installation
step.
To install the LRS operator to a kubernetes cluster, several artifacts are required:
1. A `kubeconfig` file with valid kubernetes cluster address and credentials is present.
The user which credentials are in the file must have enough permissions to create a set of objects
for the LRS operator container to run in the cluster.
2. The name of a `kubeconfig context` which contains kubernetes cluster address and credentials
is known. This may be extracted from a `kubeconfig` file when there is only one `kubeconfig context`
in the file.
3. The LRS operator docker image available on a docker registry web service by its address and
its docker image tag. There is an ability (network connectivity and auth credentials) to fetch
the docker image to the provisioner machine and run a docker container from it.
For example `docker.hq.datarobot.com/datarobot/operator-lrs:7c3321f10e` is the full docker image
ID

## Automatic LRS operator installation using datarobot installer

DataRobot installer has a `lrs_operator install` command which performs LRS operator installation
to a kubernetes cluster. It requires a `kubeconfig` file to be present in the same directory
as `config.yaml` is.

Go to the DataRobot installer directory (usually it is `/opt/tmp`) and then call:
```
./bin/datarobot lrs_operator install
```

Here is an example of a successful run output:
```
Pushing LRS operator docker image to docker registry of drca-mqg8rg4-dsp
2019-11-21 15:20:48,360 - INFO - Pushed LRS operator docker image to repo.drca-mqg8rg4-dsp.drca5.com/datarobot/operator-lrs
Start LRS operator installation into drca-mqg8rg4-dsp kubernetes cluster.
Applying manifests
Creating: Namespace
Creating: CustomResourceDefinition
CRD already exists on cluster
Creating: Role
Creating: ClusterRole
Creating: ClusterRole
Creating: RoleBinding
Creating: ClusterRoleBinding
Creating: ClusterRoleBinding
Creating: ConfigMap
Creating: Service
Creating: Deployment
Creating Registry Secret: lrs-controller-self-create-secret
LRS operator was installed into drca-mqg8rg4-dsp Kubernetes cluster
```
This operation will fail if:
* There is an instance of LRS operator with the same instance name already
installed to the kubernetes cluster;
* `kubeconfig` file is not present on disk in the same directory as `config.yaml` is.
Please make sure that `kubeconfig` file is present on the disk and has sufficient file permissions
to be copied to the `kubernetes` subdirectory;
* Docker registry service is not reachable. Please make sure that docker registry web service is
accessible with a command-line tool like `curl`;
* Docker registry username and password are not correct. You could test username and password
correctness calling `docker login -u <username> -p <password> <registry-hostname>`

## Manual LRS operator installation running a docker container (extract it)

The LRS operator installation may be performed by running a docker container with a
`--install-mode` flag. Also, it requires two environment variables to be exported into a docker
container. The `KUBECONFIG` variable must contain a path to a valid `kubeconfig` file mounted
inside the docker container. The `KUBECONFIG_CONTEXT` variable must contain a valid
`kubeconfig-context` name that is available in the `kubeconfig` file which is used to
communicate with the kubernetes cluster.

Example:
```
docker run --rm -v $KUBECONFIG:$KUBECONFIG --env-file docker-env docker.hq.datarobot.com/datarobot/operator-lrs:7c3321f10e --install-mode
```
