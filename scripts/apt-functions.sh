#!/bin/bash
################################################################################
#
# apt-functions.sh
#
# Various apt functions, use by sourcing it in either via source or .
#
# youngd24@gmail.com
# darren@yhlsecurity.com
#
################################################################################


################################################################################
#        NAME : apt_get_spinner
# DESCRIPTION : Install an apt package but wait for the lock and present a
#               spinner to the user.
#   ARGUMENTS : string(package)
#     RETURNS : 0 or 1
#       NOTES : None
################################################################################
apt_get_spinner() {

    # Make sure they gave us a package to install, return false if not
    if [[ -z "$1" ]]; then
        echo "Usage: apt_get_spinner(package)"
        return 1
    else
        # The package to be installed
        local PKG="$1"
        echo "Installing $PKG"

        # Local variable for the iterator
        local i=0

        # Init the terminal
        tput sc

        # fuser is a program to show which processes use the named files, sockets, or filesystems
        # So while the command is true
        while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do

            # The spinner
            case $(($i % 4)) in
                0 ) j="-" ;;
                1 ) j="\\" ;;
                2 ) j="|" ;;
                3 ) j="/" ;;
            esac

            # Reset the terminal
            tput rc

            # Print the spinner to the screen
            echo -en "\r[$j] Waiting for other software managers to finish..."

            # Adjust to wait longer
            sleep 0.5

            # Increment the iterator
            ((i=i+1))
        done

        # The lock is gone, install the package
        # Return true if it was successful, false if not
        # RET is the return string from the process
        # RETVAL is the shell return value
        RET=$(/usr/bin/apt-get "$@")
        RETVAL=$?
        if [[ $RETVAL != 0 ]]; then
            echo "Failed to install package, error is: $RET"
            return 1
        else
            echo "Installed package"
            return 0
        fi
    fi
}


################################################################################
#        NAME : test_dpkg_lock
# DESCRIPTION : Check if there's a dpkg lock
#   ARGUMENTS : None
#     RETURNS : Always returns true (0)
#       NOTES : It waits until the package lock is gone to return
################################################################################
test_dpkg_lock() {
    # An iterator used for counting loop iterations
    local i=0

    # fuser is a program to show which processes use the named files, sockets, or filesystems
    # So while the command is true
    while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
      # Wait half a second
      sleep 0.5

      # and increase the iterator
      ((i=i+1))
    done

    # Always return success, since we only return if there is no
    # lock (anymore)
    return 0
}
