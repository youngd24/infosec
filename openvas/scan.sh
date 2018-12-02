#!/bin/bash
#
RETVAL=$(cat create_task.xml | omp --xml -)

TMPTASK=$(echo $RETVAL | awk '{print $2}' | awk -F= '{print $2}')
TASK=$(echo $TMPTASK | tr -d \")

RETVAL=$(omp --start-task $TASK)

