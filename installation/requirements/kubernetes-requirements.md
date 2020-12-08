# DataRobot Kubernetes Requirements

*NOTE*: These requirements refer to installing kubernetes as part of the DataRobot installation on a separate host. They are not completely relevant to other scenarios (such as using externalized kubernetes e.g. EKS).

Summary of requirements for DataRobot-installed kubernetes:

* Separate 8+vCPU/32+GB RAM Centos/RHEL7 SELinux-permissive host to install `kubernetes.io` distro of kubernetes `1.18.x` as `root`
* Separate kubernetes host has at least _one additional outgoing IP address_
* Ability to modify `/etc/hosts` entries (or manually setting up DNS)

## Operating System

The only supported operating system for DataRobot-installed kubernetes is Centos/RHEL7 with SELinux permissive.

## Hostnames / DNS

Either through modifying `/etc/hosts` or using manually-configured DNS, several hostnames are required. Raw IP addresses cannot be used.

| hostname | IP address | Resolvability |
|----------|------------|---------------|
| cm0 | Custom models nginx ingress binding IP | All DataRobot application and kubernetes hosts |
| registry | Image builder registry host IP | All DataRobot application and kubernetes hosts |

When DataRobot-installed kubernetes is used, the `cm0` hostname is bound to an additional outgoing IP address available on the kubernetes host. This IP gets delegated by `metallb` in kubernetes.

## TLS

Either through modifying docker-allowed certificates or using manually-configured TLS/SSL verification chain, valid, verifiable TLS certificates are required.

| hostname | service | Verifiability |
|----------|---------|---------------|
| registry | Image builder registry | docker daemon on all DataRobot application and kubernetes hosts |

## Ports

In addition to the standard install ports, additional ports are required for kubernetes.

| Port Range | Description | Host  | Accessibility |
|------------|-------------|-------|---------------|
| 22 | Kubernetes SSH | Kubernetes | DataRobot provisioner host |
| 80 | Kubernetes ingress controller HTTP | Kubernetes (additional IP) | All DataRobot application and kubernetes hosts |
| 443 | Image builder registry HTTPS | Image builder registry | All DataRobot application and kubernetes hosts |
| 443 | Kubernetes ingress controller HTTPS | Kubernetes (additional IP) | All DataRobot application and kubernetes hosts |
| 2379-2380 | Kubernetes etcd | Kubernetes | All kubernetes hosts |
| 6443 | Kube API HTTPS endpoint | Kubernetes | All DataRobot application and kubernetes hosts |
| 10250-10252 | Internal kubernetes communication | Kubernetes | All kubernetes hosts |

SSH access to the kubernetes host (port 22) is assumed, similar to standard installation.
Port 443 must be open on the image builder registry host (typically kubernetes host) and accessible by all DataRobot application and kubernetes hosts.
Ports 80/443 must be usable by an additional IP address on the kubernetes host(s) for the nginx ingress controller used to route to the custom models. This must be accessible from all DataRobot application and kubernetes hosts.
The kubernetes node will need port 6433 open for the kubernetes API https endpoint. It must be accessible from all DataRobot application and kubernetes hosts.
Ports 2379-2380 must be accessible between all kubernetes host(s) for `etcd` used internally by kubernetes.

## Kubernetes Host

A separate Centos/RHEL7 machine or VM on which to install kubernetes 1.18.5 as `root` is required. The supported configuration is Centos/RHEL7 with SELinux permissive, and other configurations are not be tested for regressions.

At least 8 vCPU and 32 GB RAM is recommended for this machine or VM ("node").

### Additional IP Address

This kubernetes node will require at least one additional outgoing IP address, which can be reached from the DataRobot application nodes. This IP address is assigned to the kubernetes nginx ingress controller running the custom models and is associated with a hostname `cm0` in the selected domain. In the recommended setup, `metallb` delegates this IP for use by custom models.

The DataRobot application nodes must be able to reach the kubernetes nodes at this IP address and using the `cm0` hostname in the selected domain (either from manual DNS setup or by editing `/etc/hosts` file on all hosts).

These IPs are to be "owned" by `metallb` to assign to kubernetes resources. For example, in EC2, secondary IP addresses can be added to the kubernetes node, and `metallb` can be configured to use at least one of those. In another scenario, the router or in-house networking team may delegate out additional IPs that `metallb` can be configured to use.

### Kubeconfig

A static kubeconfig file must be provided which allows passwordless access to the kubernetes servers via `kubectl`. This kubeconfig file must grant sufficient privilege such that the account/context specified can connect to the kubernetes server and apply manifests in the `kube-system` namespace, as well as creating additional namespaces.

When Datarobot-installed kubernetes is used, we initially re-use the `admin.conf` file created from `kubeadm`.

### Image Builder Registry(ies)

A docker registry is required to cache custom model base and managed images (the reference data for these images lives in the storage (e.g. minio, S3), but they are pulled into this registry to be used). It is stood up as part of the DataRobot installation on the host with the `registryimagebuilder` service in `config.yaml`.

This registry will require additional disk space for these cached docker images depending on the size and number of custom models in use. It can run on the same machine as the kubernetes node.

(As a further optimization, this same node can optionally run the `execmanagerunsecuredimagebuilder` and `execmanagerimagebuilder` services, so the temporary storage utilized for image building, and pushing to the image builder registry which kubernetes pulls from, is all co-located, with additional disk space allocated to `/var/lib/docker` and temporary storage for `execmanager*`).

It requires binding to the host port 443. It must be reachable from all DataRobot application and kubernetes host(s) on port 443 using a FQDN hostname (not an IP address) and valid TLS certificate which can be verified (i.e. not self-signed).

This hostname needs to resolve to the host running the image builder registry(ies), e.g. by editing `/etc/hosts` on all hosts, or via manually using customer-provided DNS to create records associating this hostname with IP address (e.g. Route53).

### TLS Certificates and Auth

TLS certificates for the image builder registry must be valid, verifiable TLS certificates, which can be verified by both the kubernetes hosts and DataRobot application hosts. Specifically, the docker daemons on each must be able to verify the image builder registry certificate.

As part of DataRobot-installed kubernetes installation, we use the kubernetes CA certificate to create a registry certificate our image builder registry will use. The registry cert will be distributed to the node running the image builder registry (typically just the kubernetes node itself). This kubernetes CA certificate is also distributed to all DataRobot application hosts and kubernetes host(s) so `docker` can verify the image builder registry (so that `execmanager*` can push to it).
