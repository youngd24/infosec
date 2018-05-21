#!/usr/bin/env python
################################################################################
#
# Python Kombu hello publisher
#
# Basic script to test out if a backend message queue and a local python is
# working correctly. Run this then run the consumer.
#
################################################################################
from __future__ import absolute_import, unicode_literals

import datetime
from kombu import Connection

with Connection('amqp://appuser:xxx@c2:5672/appvhost') as conn:
    simple_queue = conn.SimpleQueue('simple_queue')
    message = 'helloworld, sent at {0}'.format(datetime.datetime.today())
    simple_queue.put(message)
    print('Sent: {0}'.format(message))
    simple_queue.close()
