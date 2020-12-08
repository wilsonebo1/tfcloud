# Kubernetes Installation Instructions

Installation will be very similar to other docker-based installs. As part of the installation, we will setup a kubernetes control plane and apply necessary amenities needed for running DataRobot kubernetes applications.

All images, kubernetes manifests, and other packages are included in the installer bundle.

### config.yaml

A host must be configured for the kubernetes control plane (`kubernetescontrolplane` service in `config.yaml`). Typically, we will co-locate registry (`registryimagebuilder`) and optional workers relevant for the image builder (`execmanagerimagebuilder` and `execmanagerunsecuredimagebuilder`) on the same host (this limits network traffic overhead for image builder and registry building and transferring of images used for custom models). Additionally, kubernetes-related application configuration and kubernetes cluster information must be included in `config.yaml`.

Some `config.yaml` options exist to affect the image builder registry settings:

```yaml
os_configuration:
  registryimagebuilder:
    # set False to disable creating/distributing TLS certs for image builder registry
    create_certs: true

    # set False to disable writing registry.test entry to /etc/hosts
    create_hosts_entry: true

    # set hostname
    hostname: "registry.test"

    # set username:password (encode via htpasswd, defaults to "datarobot:Registry123")
    htpasswd: "datarobot:$2y$05$Ss92wdQZFXpqQ6iwohMSXOegBXfU.jBR.2p4gFCmbKMMUekRExCui"
```


### setup-dependencies

The `bin/datarobot setup-dependencies` command will install kubernetes control plane as `root` on the host indicated with `kubernetescontrolplane` in `config.yaml`.

`kubectl` is installed for convenience on that host, and is available in the release packages of the installation directory.

If `metallb` is used, the first address in its configured pool will be written into `/etc/hosts` on all hosts as `cm0.datarobot.test` (unless customer-provided DNS is used).

Additionally, when `registryimagebuilder` is used, it will add the kubernetes CA into the docker daemon certificate chain on all hosts, and modify `/etc/hosts` on all hosts to add the IP address for the host running `registryimagebuilder` as `registry.test`.

### install

Since we are only able to `sudo` as `root` during `setup-dependencies`, all tasks during `bin/datarobot install` run as a non-privileged user.

On the host marked `registryimagebuilder`, the image builder registry, bound to port 443, will be stood up. A registry certificate is created (using the kubernetes CA distributed during `bin/datarobot setup-dependencies`), and `htpasswd` username/password authentication is set up (defaulting to "datarobot:Registry123").

A `kubernetescontrolplane` container is started running a "kubernetes watcher". This waits for ability to access kubernetes API using `kubeconfig` and then applies all "amenities" (packages of kubernetes manifests to install into kubernetes) during `bin/datarobot install`. This sets up networking, ingress, and other amenities e.g. as required by LRS used by custom models (e.g. setting up `calico`, `metallb`, `nginx-ingress`, etc.).

### health smoke-test

Additional health checks have been added to the `availabiltymonitor` which can be checked during `bin/datarobot health smoke-test`:

  * `kubernetescontrolplane` -- health checks for kubernetes API (access :6443), `etcd`, and control plane health checks (kubernetes API, scheduler, etc.)

### LRS operator

For custom models, "Long Running Services" (LRS) is required. This must be installed _after_ the above completes and `availabilitymonitor` indicates `kubernetescontrolplane` health.

```shell
bin/datarobot lrs_operator install-webhook-and-crd
bin/datarobot lrs_operator install
bin/datarobot lrs_operator set-active
```
