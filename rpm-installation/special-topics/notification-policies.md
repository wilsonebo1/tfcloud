# Notification Policies

DataRobot supports Notification Policies system that allows system admins to configure Notification Channels and Policies to subscribe to notifications when certain events happen in the system.

This functionality is in Public Beta now and should be enabled for the cluster if you want to start using it.

## Configuration

We have a separate service called `notificationsbroker` that needs to be deployed to the cluster to process notifications. 
Make sure that it's listed in your `config.yaml` under the `services` section.

We have configuration variable `ENABLE_NOTIFICATION_SERVICE` that controls if Notification Policies functionality should be enabled for the install. Set it to `true` in your `app_configuration`.

Example:


```
app_configuration:
  drenv_override:
    ENABLE_NOTIFICATION_SERVICE: true
...
servers:
- services:
  ...
  - notificationsbroker
```

There are additional settings that can be used to configure Notification Policies functionality:

* **ENABLE_NOTIFICATION_SERVICE** (default: *False*): Enable Notification Service
* **NOTIFICATIONS_RETRY_DELAY** (default: *30*): Delay between notification webhook retries in seconds. Multiplied to retry number.
* **NOTIFICATIONS_MAX_RETRY_COUNT** (default: *3*): Max retry count for notification webhooks.
* **NOTIFICATIONS_WEBHOOK_REQUEST_TIMEOUT_SECONDS** (default: *5*): Notification webhook request timeout in seconds.

## Usage

Only admin users can setup Notification Channels and Policies. Users should have "Can Manage Notification Policies" Early Release Feature to be enabled. See DataRobot Documentation for guidance on how to set up and use Notification Policies.
