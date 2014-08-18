#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vim: set ts=4 sw=4 et sts=4 ai:

import os
import time

from libcloud.compute.types import Provider, NodeState
from libcloud.compute.providers import get_driver


XILINX_AMI = 'ami-efd5b3d5'


def node_created(node, ip_addr):
    print('Node is now up with IP %r: %r' % (ip_addr, node,))

    # Here: connect to host, perform build, check result, exit.

    # Allow control of termination.
    finished = ""
    while finished != "yes":
        finished = raw_input("Type 'yes' to terminate the instance:").lower()


def main():
    aws_key = os.environ.get('AWS_KEY')
    aws_secret = os.environ.get('AWS_SECRET')

    if not (aws_key and aws_secret):
        print 'AWS_KEY and AWS_SECRET must both be set in the environment.'
        exit(1)

    # Set up EC2 driver.
    cls = get_driver(Provider.EC2_AP_SOUTHEAST2)
    driver = cls(aws_key, aws_secret)

    # Get desired size and the AMI image to base the instance on.
    size = [x for x in driver.list_sizes() if 'micro' in x.id][0]
    image = [x for x in driver.list_images() if x.id == XILINX_AMI][0]

    # Here: set up SSH pairs (or load a key from EC2), create deployment, etc...

    # Create instance from the found AMI.
    node = driver.create_node(name='xilinx_ec2', size=size, image=image)
    try:
        nodes = driver.wait_until_running([node])
        for running_node, ip_addr in nodes:
            node_created(running_node, ip_addr)
    except:
        raise
    finally:
        # Terminate the instance.
        node.destroy()


if __name__ == '__main__':
    main()
