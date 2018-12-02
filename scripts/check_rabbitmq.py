#!/usr/bin/env python
################################################################################
#
# check_rabbitmq.py
#
# Script to check whether or not RabbitMQ is running on a given host
#
# Darren Young [darren@yhlsecurity.com] [youngd24@gmail.com]
#
################################################################################

# imports of modules
import sys
import os
import argparse
import pika

# define and parse command-line options
# argparse is so yucky
parser = argparse.ArgumentParser(description='Check connection to RabbitMQ server')
parser.add_argument('--server', required=True, help='Define RabbitMQ server')
parser.add_argument('--virtual_host', default='/', help='Define virtual host')
parser.add_argument('--ssl', action='store_true', help='Enable SSL (default: %(default)s)')
parser.add_argument('--port', type=int, default=5672, help='Define port (default: %(default)s)')
parser.add_argument('--username', default='guest', help='Define username (default: %(default)s)')
parser.add_argument('--password', default='guest', help='Define password (default: %(default)s)')
args = vars(parser.parse_args())

# set amqp credentials
credentials = pika.PlainCredentials(args['username'], args['password'])

# set amqp connection parameters
parameters = pika.ConnectionParameters(host=args['server'],\
                                       port=args['port'], \
                                       virtual_host=args['virtual_host'], \
                                       credentials=credentials, \
                                       ssl=args['ssl'])

# try to establish connection and check its status
try:
  connection = pika.BlockingConnection(parameters)
  if connection.is_open:
    print('OK')
    connection.close()
    exit(0)
except Exception as error:
  print('Error:', error.__class__.__name__)
  exit(1)
