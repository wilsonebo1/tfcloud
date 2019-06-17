# Quick Workers Jobs on EDGE node

When DataRobot is deployed to heavily used Hadoop clusters, it might take
some time to allocate containers for jobs. This may lead to poor user experience.
If this is the case, we recommend using pre-allocated containers
(also known as Quick Workers) for the jobs that are responsible for creating
new projects and coordinating autopilot.

Quick Workers containers are regular containers which listen to messages
from Application Master and execute "quick" jobs.

In DataRobot 5.0 they were replaced with a new execution manager `execmanagerqw` on the EDGE node.
That component is responsible for processing the following types of jobs:

* `DSS_REST`
* `NEXT_STEPS`

## Configure DataRobot

There are 2 steps in order to process `DSS_REST` and `NEXT_STEPS` from Hadoop to EDGE node:

* disable `DSS_REST` and `NEXT_STEPS` services at Hadoop side
* configure new execution manager for `DSS_REST` and `NEXT_STEPS` jobs processing

### Disable DSS_REST and NEXT_STEPS services on Application Master

There is flag in `config.yaml` which forces Application Master to skip listening `DSS_REST` and `NEXT_STEPS` rabbit queues

```yaml

---
app_configuration:
    drenv_override:
        SKIP_DSS_REST_AND_NEXT_STEPS_SERVICES: true
```

### Configure execmanagerqw on EDGE node

Add new service `execmanagerqw`
```yaml

---
- services:
  - execmanagerqw
  hosts:
  - 192.168.1.8
```
