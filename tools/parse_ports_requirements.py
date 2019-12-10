# -*- coding: utf-8 -*-
"""Tool to parse ports from network requirements."""
from __future__ import absolute_import, print_function

import json
import re

from collections import defaultdict

import click


PROTOCOLS = ['tcp', 'udp']
HADOOP_WORKERS = ['cdh_worker', 'ambari_worker']
HADOOP_MASTERS = ['cdh_master', 'ambari_master']
ALL_HADOOP_NODES = HADOOP_WORKERS + HADOOP_MASTERS
ALL_APPLICATION_NODES = ['webserver']

TARGET_MAPPING = {
    'All Cloudera Nodes': ['cdh_master', 'cdh_worker'],
    'All Hadoop Nodes': ALL_HADOOP_NODES,
    'Ambari Manager': ['ambari_master'],
    'Analytics Broker Node': ALL_APPLICATION_NODES,
    'Application Servers': ALL_APPLICATION_NODES,
    'Application Web Servers': ALL_APPLICATION_NODES,
    'Cloudera Manager': ['cdh_master'],
    'Cloudera workers': ['cdh_worker'],
    'Data Servers': ALL_APPLICATION_NODES,
    'Hadoop workers': HADOOP_WORKERS,
    'Hortonworks workers': ['ambari_worker'],
    'Model Management': ALL_APPLICATION_NODES,
    'Patroni Nodes': ['Application Servers', 'Patroni Nodes'],
    'Provisioner/Admin': ALL_APPLICATION_NODES,
    'RabbitMQ node': ALL_APPLICATION_NODES,
}


@click.command()
@click.argument('network_requirements', required=True, type=click.File('r'))
def parse(network_requirements):
    """This script produces json with ports required.

    It uses the network requirement file as an argument.
    """
    # Read not relevant information, which goes before the table.
    line = network_requirements.readline()
    while line:
        if re.search(r'#+\s+All Ports In One Table', line):
            break
        line = network_requirements.readline()
    line = network_requirements.readline()
    while line:
        if re.search(r'^\|Port\|Protocol', line):
            break
        line = network_requirements.readline()
    # Read horizontal bar
    network_requirements.readline()
    data = defaultdict(lambda: defaultdict(lambda: defaultdict(lambda: defaultdict(list))))
    for line in network_requirements:
        _, port, documented_protocol, _, dst, src, _ = line.split('|')

        for protocol in PROTOCOLS:
            if protocol in documented_protocol.lower():
                targets = dst.split(', ')
                for target in targets:
                    for trgt in TARGET_MAPPING[target]:
                        scope = 'internal' if src == dst else 'all'
                        data[trgt]['sg_open_ports'][protocol][scope].append(int(port))

    print(json.dumps(data))


if __name__ == '__main__':
    # pylint: disable=no-value-for-parameter
    parse()
