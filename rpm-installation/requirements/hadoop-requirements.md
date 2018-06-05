{% extends "hadoop-requirements.base.md" %}o

{# no Ambari on RPM 4.2.2 #}
{% block hadoop_integration_requirements %}
# DataRobot Hadoop Integration Requirements

DataRobot is installable as a parcel that can run on your organization's
Hadoop cluster.

DataRobot can integrate with Cloudera Hadoop distribution.
{% endblock %}

{# no ETL on RPM 4.2.2 #}
{% block optional_scalable_ingest_requirements %}
{% endblock %}

{# no Ambari on RPM 4.2.2 #}
{% block ambari_requirements %}
{% endblock %}
