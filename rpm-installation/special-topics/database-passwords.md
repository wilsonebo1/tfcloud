{% extends "database-passwords.base.md" %}

{% block enable_secrets_command %}
```bash
./bin/datarobot install --pre-configure
./bin/datarobot services restart
./bin/datarobot install --post-configure
```
{% endblock %}

{% block disable_secrets_command %}
```bash
./bin/datarobot install --pre-configure
./bin/datarobot services restart
./bin/datarobot install --post-configure
```
{% endblock %}
