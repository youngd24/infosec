#!/usr/bin/env python
################################################################################
#
# Python Kombu hello consumer
#
################################################################################
from __future__ import absolute_import, unicode_literals, print_function
from kombu import Connection

with Connection('amqp://appuser:xxx@c2:5672/appvhost') as conn:
    simple_queue = conn.SimpleQueue('simple_queue')
    message = simple_queue.get(block=True, timeout=1)
    print('Received: {0}'.format(message.payload))
    message.ack()
    simple_queue.close()
