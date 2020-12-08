# -*- coding: utf-8 -*-
"""Tests tools/parse_ports_requirements.py."""
from __future__ import absolute_import

import json
import os

import pytest

from click.testing import CliRunner

from tools import parse_ports_requirements as ppr


NR_FILES = [
    'installation/requirements/network-requirements.md',
    'rpm-installation/requirements/network-requirements.md',
]


@pytest.mark.parametrize('test_file', NR_FILES)
def test_ports_parse_output(test_file):
    """Test can parse JSON output for ports."""
    nr_file = os.path.abspath(os.path.join(__file__, '..', '..', test_file))

    runner = CliRunner()
    with runner.isolated_filesystem():
        result = runner.invoke(ppr.parse, [nr_file])

    assert result.exit_code == 0

    json_out = json.loads(result.output)
    labels = ['webserver', 'cdh_master', 'cdh_worker', 'cdh_master', 'cdh_worker']
    for label in labels:
        check = len(json_out[label]['sg_open_ports']['tcp']['all']) > 0
        message = 'TCP ports for {} are not present'.format(label)
        assert check, message


def get_port_number(line):
    """Get port number in line."""
    if not line.startswith('|'):
        return []
    first_element = line.split('|')[1].strip()
    if first_element.isdigit():
        return [int(first_element)]
    if '-' in first_element and len(first_element.split('-')) == 2:
        first, second = first_element.split('-')
        if first.isdigit() and second.isdigit():
            return range(int(first), int(second) + 1)
    return []


def get_ports_from_lines(lines):
    """Get set of ports from all lines."""
    res = set()
    for line in lines:
        port_numbers = get_port_number(line)
        res.update(port_numbers)
    return res


@pytest.mark.parametrize('test_file', NR_FILES)
def test_table_and_description_match(test_file):
    """Verify that ports listed in 'All Ports' table are found.

    Checks in the description sections above, and vice versa.
    """

    table_line = '## All Ports In One Table\n'
    with open(test_file) as f:
        lines = f.readlines()

    # Get the line number where the "All Ports" table starts
    table_position = lines.index(table_line)

    # Fetch all of the ports in the description section of the document
    description_ports = get_ports_from_lines(lines[:table_position])

    # Fetch all of the ports in the "All Ports" section of the document
    table_ports = get_ports_from_lines(lines[table_position:])

    assert len(description_ports) > 0, 'No ports were found with separate descriptions'
    assert len(table_ports) > 0, 'No ports were found in the table'
    not_in_table = description_ports - table_ports
    table_msg = 'These ports are missing in the table: {}'.format(
        ', '.join(str(x) for x in not_in_table)
    )
    assert not not_in_table, table_msg
    not_in_description = table_ports - description_ports
    desc_msg = 'These ports are missing separate description: {}'.format(
        ', '.join(str(x) for x in not_in_description)
    )
    assert not not_in_description, desc_msg
