#!/bin/bash
################################################################################
#
# start_rabbitmq.sh
#
# Script to start RabbitMQ manually, originally used on a Mac to watch it
#
################################################################################

OS=$(uname -s)
TRUE="/usr/bin/true"
FALSE="/usr/bin/false"

case $OS in
    "Darwin")
        echo "Starting RabbitMQ server manuall on OS: $OS"
        sudo rabbitmq-server
        exit $(TRUE)
        ;;
    "Linux")
        echo "Starting RabbitMQ server manuall on OS: $OS"
        exit $(TRUE)
        ecit 0
        ;;
    *) echo "Script unable to work on OS: $OS"
       exit $(FALSE)
       exit 1
esac
