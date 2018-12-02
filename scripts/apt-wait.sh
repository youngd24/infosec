#!/bin/bash
################################################################################
#
# apt-wait.sh
#
# Apt does not look to see if another dpkg/apt proc has the lock open and
# wait to get it which means doing things via scripts is a PITA. This helps
# to limit that pain.
#
# youngd24@gmail.com
# darren@yhlsecurity.com
#
################################################################################

i=0
tput sc
while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    case $(($i % 4)) in
        0 ) j="-" ;;
        1 ) j="\\" ;;
        2 ) j="|" ;;
        3 ) j="/" ;;
    esac
    tput rc
    echo -en "\r[$j] Waiting for other software managers to finish..."
    sleep 0.5
    ((i=i+1))
done

/usr/bin/apt-get "$@"

