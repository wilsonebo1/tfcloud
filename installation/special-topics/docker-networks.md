# Docker networks

## Overview

Starting in DataRobot version 5.3, networking for Docker-based installs is now configurable. Two additional configuration options have been added to aid in advanced network customization. Typically these options will be set in order to avoid network routing overlap.


## Prerequisites

In the event that you opt to configure the Docker networks, we recommend that you consult with you network administrator to locate a /22 (recommended) or /24 block of address space. If you opt for the /22 option we recommend that /25's be handed out by Docker. If you opt for a /24 block of space, we recommend that Docker hand out /26's.


## Configuration overview

`config.yaml` now supports customizing Docker networks.  Both settings can be added under the os_configuration
key. Both of these settings are optional, the recommendation is that only docker_network_pools is set.
    * We recommend a /22 CIDR block handed out as /25's. A minimal setup would be a /24 split in to /26's
    * Please confirm with your network administrator that the CIDR blocks you choose are not in use.
    * Settings should be configured as follows:
        * `docker_network_bip`: this configures the cidr block and gateway to use for the bridge interface. *We reccomend that this remains unset*. This is available for advanced scenarios.
            * please note that the bip setting should contain the gateway address
                * good setting: "192.168.0.1/25"
                * bad setting: "192.168.0.0/25"
        * `docker_network_pools`: this configuration allows configuration of the networks Docker automatically hands out.

## Ideal configuration example

Here is an ideal/recommended configuration example, note the omission of `docker_network_bip`:

```yaml
---
os_configuration:
  docker_network_pools:
    - base: 172.17.0.0/22
      size: 25
```

## Sample advanced configuration

```yaml
---
os_configuration:
  docker_network_bip: 192.168.0.1/24
  docker_network_pools:
    - base: 172.17.0.0/22
      size: 25
```
