#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

source jarvis-autotest/common.sh

_note "Running Test"
set -x

pip install -r tests/test_requirements.txt
python -m pytest -svv tests/tests_network_requirements.py

set +x
