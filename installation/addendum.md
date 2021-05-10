# Addendum

## RPM Files Included

The DataRobot application comes with a small number of `rpm` packages required for installation and administration of the service.


### Docker Dependencies (Required)

| Dependency | RHEL/CentOS 7 | RHEL/CentOS 8 |
|:-----------|:----------------|:----------------|
| Docker Engine  | `docker-ce-19.03.12-3.el7.x86_64.rpm` |  `docker-ce-19.03.12-3.el7.x86_64.rpm` |
| Docker CLI  | `docker-ce-cli-19.03.12-3.el7.x86_64.rpm` | `docker-ce-cli-19.03.12-3.el7.x86_64.rpm` |
| Container Runtime  | `containerd.io-1.2.13-3.2.el7.x86_64.rpm` | `containerd.io-1.2.13-3.2.el7.x86_64.rpm` |
| Container SELinux Policy  | `container-selinux-2.119.2-1.911c772..el7_8.noarch.rpm` | `container-selinux-2.135.0-1.module+el8.2.1+6849+893e4f4a.noarch.rpm` |
| SELinux Python Utils  | | `policycoreutils-python-utils-2.9-9.el8.noarch.rpm` |


### Custom Models Dependencies (RHEL/CentOS 7 Only)

| Package |
|:--------|
| `cri-tools-0.1.13.0-0.x86_64.rpm` |
| `kubeadm-1.18.5-0.x86_64.rpm` |
| `kubectl-1.18.5-0.x86_64.rpm` |
| `kubelet-1.18.5-0.x86_64.rpm` |
| `kubernetes-cni-0.8.6-0.x86_64.rpm` |


## 3rd Party Components Included

The DataRobot application includes the following versions of 3rd party components:

| Component          | Version   |
|:-------------------|:----------|
| Elasticsearch      | 6.8.1     |
| HAProxy            | 2.3.1     |
| MinIO              | 2021.1.16 |
| MongoDB            | 3.6.14    |
| Nginx              | 1.18.0    |
| PostgreSQL         | 10.13     |
| RabbitMQ           | 3.8.9     |
| Redis              | 6.0.8     |
