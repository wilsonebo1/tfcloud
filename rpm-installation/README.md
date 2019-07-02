# DataRobot Installation and Configuration Guide

Welcome to the DataRobot Administration Guide.

This manual describes how to install, configure, and maintain your DataRobot
installation.

<img src="images/datarobot-robot.png" alt="datarobot-logo"/>

## DataRobot Architecture

### Linux

The following diagram illustrates the high-level architecture of the DataRobot
Linux installation.

<img src="images/architecture.png" alt="datarobot-architecture"/>

**NOTE**: Unless otherwise specified, "Linux" is applicable to all supported
Linux distributions and versions. Where there is something specific to a
particular distribution or version, it is mentioned explicitly.

### Hadoop

When DataRobot is integrated with Hadoop, the DataRobot cluster architecture is
modified to add a YARN Application Master that handles resources in Hadoop.

<img src="images/hadoop-arch.png" style="border:1px solid black"/>

**NOTE**: Unless otherwise specified, "Hadoop" is applicable to Cloudera clusters.
