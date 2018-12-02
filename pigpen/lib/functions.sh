###############################################################################
#
# functions.sh
#
# Shared shell script functions used by various other scripts. It must be 
# sourced in to work, don't call it directly. Use a '.' or the source 
# command to pull it in. How i'm doing it:
#
#    DIRNAME=$(dirname $0)
#    LIBDIR="$DIRNAME/../lib"
#    source "$LIBDIR/functions.sh"
#
# That determines the full path of the script being run then sets the file to
# source in up a directory in lib.
#
###############################################################################


###############################################################################
# Print a log formatted message
# If LOGFILE is defined the output will go there otherwise it goes to STDOUT
###############################################################################
function logmsg() {
    if [[ -z "$1" ]]
    then
        errmsg "Usage: logmsg <message>"
        return 0
    else
        local MESSAGE=$1
        if [[ ! -z $LOGFILE ]]; then
            local NOW=`date +"%b %d %Y %T"`
            echo $NOW $1 >> $LOGFILE
        else
            local NOW=`date +"%b %d %Y %T"`
            msg "$NOW $MESSAGE" 
            return 0
        fi
    fi

}


###############################################################################
# Print a message to stderr so it doens't become part of a function return
###############################################################################
function errmsg() {
    if [[ -z "$1" ]]; then
        logmsg "Usage: errmsg <message>"
        return 0
    else
        logmsg "ERROR: $1"
        return 1
    fi
}


###############################################################################
# Print a message if global $DEBUG is set to true
###############################################################################
function debug() {
    if [[ -z "$1" ]]
    then
        errmsg "Usage: debug <message>"
        return 0
    else
        if [ "$DEBUG" == "true" ]
        then
            local message="$1"
            logmsg "DEBUG: $message" 
            return 1
        else
            return 1
        fi
    fi
}


###############################################################################
###############################################################################
function create_backup_dir() {
    debug "${FUNCNAME[0]}(): entering"

    if [ ! -d $BACKUPDIR ]; then
        logmsg "Creating backup directory $BACKUPDIR"
        mkdir $BACKUPDIR
        return 1
    else
        logmsg "Backup directory $BACKUPDIR already in place"
        return 1
    fi
}


###############################################################################
# Modify the sshd config file for local changes
###############################################################################
function set_sshd_config() {
    debug "${FUNCNAME[0]}(): entering"

    RESULT=$(grep "PermitRootLogin yes" /etc/ssh/sshd_config)
    RETVAL=$?

    if [[ $RETVAL = 0 ]]; then
        logmsg "PermitRootLogin yes is set, nothing to do so leaving"
        return 1
    else
        RESULT=$(grep "#PermitRootLogin prohibit-password" /etc/ssh/sshd_config)
        RETVAL=$?

        if [[ $RETVAL = 0 ]]; then
            logmsg "PermitRootLogin prohibit-password is set, setting to yes"
            cp /etc/ssh/sshd_config /backup/sshd_config
            echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

            logmsg "Reloading SSH service"
            run_command "systemctl restart ssh.service"
            return 1
        else
            return 1
            logmsg "not 0"
        fi
    fi
}


###############################################################################
# Regenerate sshd host keys
# This is in no way polite, it forces it by default
# TODO: Make this a bit more polite
###############################################################################
function generate_sshd_hostkeys() {
    debug "${FUNCNAME[0]}(): entering"

    logmsg "Backing up current host keys"
    run_command "cp /etc/ssh/*host* $BACKUPDIR"

    logmsg "Removing current host keys"
    run_command "rm -f /etc/ssh/ssh_host*"

    logmsg "Regenerating host keys via dpkg-reconfigure"
    run_command "dpkg-reconfigure openssh-server"

    return 1

}


###############################################################################
# Run a command
###############################################################################
function run_command() {
    debug "${FUNCNAME[0]}: entering"

    if [[ -z "$1" ]]
    then
        errmsg "Usage: run_command <command>"
        return 0
    else
        local CMD="$1"
        debug "CMD: $CMD"
        RET=$($CMD >> $LOGFILE 2>>$LOGFILE)
        RETVAL=$?

        debug "return: $RET"
        debug "retval: $RETVAL"

        if [[ $RETVAL != 0 ]]; then
            logmsg "Failed to run command"
            return 0
        else
            debug "SUCCESS"
            return 1
    fi
        return 1
    fi

}


###############################################################################
# Update apt
###############################################################################
function apt_update() {
    debug "${FUNCNAME[0]}(): entering"
    logmsg "Updating apt"
    CMD="apt-get -q -y update"
    logmsg "Running command $CMD"
    run_command "$CMD"
}


###############################################################################
# Apt cleanup
###############################################################################
function apt_cleanup() {
    debug "${FUNCNAME[0]}(): entering"
    logmsg "Cleaning up apt"
    CMD="apt autoremove"
    logmsg "Running command $CMD"
    run_command "$CMD"
}


###############################################################################
# Install a package using apt
###############################################################################
function apt_install() {
    debug "${FUNCNAME[0]}(): entering"
    if [[ -z "$1" ]]
    then
        errmsg "Usage: apt_install <package>"
        return 0
    else
        local PKG="$1"
        debug "PKG: $PKG"
        logmsg "Installing system package: $PKG"
        local CMD="apt-get -q -y install $PKG"
        logmsg "Running command '$CMD'"
        run_command "$CMD"
        return 1
    fi
}


###############################################################################
# Install a Python package using pip
###############################################################################
function pip_install() {
    debug "${FUNCNAME[0]}(): entering"
    if [[ -z "$1" ]]
    then
        errmsg "Usage: pip_install <package>"
        return 0
    else
        local PKG="$1"
        debug "PKG: $PKG"
        logmsg "pip installing python package: $PKG"
        local CMD="pip install $PKG"
        logmsg "Running command '$CMD'"
        run_command "$CMD"
        return 1
    fi
}


###############################################################################
# Set the local hostname based off the mac address. Do this in the hostname
# and hosts file
###############################################################################
function set_hostname() {
    debug "${FUNCNAME[0]}(): entering"
    HOSTNAME=$($DIRNAME/../bin/hostname.py)
    logmsg "Setting hostname => $HOSTNAME"

    logmsg "Backing up current files"
    logmsg "Backing up $HOSTSFILE"
    run_command "cp $HOSTSFILE $BACKUPDIR/"

    logmsg "Backing up $HOSTNAMEFILE"
    run_command "cp $HOSTNAMEFILE $BACKUPDIR/"

    RET=$(grep kali $HOSTSFILE)
    RETVAL=$?
    if [[ $RETVAL = 0 ]]; then
        logmsg "Modifying $HOSTSFILE"
        echo "127.0.0.1       $HOSTNAME   localhost" > /tmp/hosts.tmp
        cat $HOSTSFILE | grep -v kali >> /tmp/hosts.tmp
        run_command "mv /tmp/hosts.tmp $HOSTSFILE"
        logmsg "Done with $HOSTSFILE"
    else
        logmsg "$HOSTSFILE already set for this hostname"
    fi

    RET=$(grep $HOSTNAME $HOSTNAMEFILE)
    RETVAL=$?
    if [[ $RETVAL = 1 ]]; then
        logmsg "Modifying $HOSTNAMEFILE"
        echo $HOSTNAME > $HOSTNAMEFILE
        logmsg "Done with $HOSTNAMEFILE"
    else
        logmsg "$HOSTNAMEFILE already set for this hostname"
    fi

    logmsg "Running hostname command"
    run_command "hostname $HOSTNAME"
    logmsg "Done running hostname command"

    return 1
}


###############################################################################
# 
###############################################################################
function touch_firstbootfile() {
    debug "${FUNCNAME[0]}(): entering"

    if [[ "$1" == "force" ]]; then
        logmsg "Force remove requested"
        if [[ -f $FIRSTBOOTFILE ]]; then
            logmsg "File exists, forcing removal"
            run_command "rm -f $FIRSTBOOTFILE"
            run_command "touch $FIRSTBOOTFILE"
            return 1
        else
            logmsg "Force requested but file not there, creating anyways"
            run_command "rm -f $FIRSTBOOTFILE"
            run_command "touch $FIRSTBOOTFILE"
            return 1
        fi
    else
        logmsg "Force not requested"
        if [[ -f $FIRSTBOOTFILE ]]; then
            logmsg "File exists and force not requested, do nothing"
            return 0
        else
            logmsg "File doens't exist and force not requested, creating"
            run_command "touch $FIRSTBOOTFILE"
            return 1
        fi
    fi
}


###############################################################################
# 
###############################################################################
function remove_firstbootfile() {
    debug "${FUNCNAME[0]}(): entering"

    logmsg "Removing firstbootfile"
    run_command "rm -f $FIRSTBOOTFILE"
    return 1
}


###############################################################################
# 
###############################################################################
function set_timezone() {
    debug "${FUNCNAME[0]}(): entering"

    if [[ -z "$1" ]]; then
        logmsg "You have to pass me a timezone like America/Chicago"
        return 0
    else
        local TZ="$1"
        logmsg "Setting timezone to $TZ in $TIMEZONEFILE"
        echo $TZ > $TIMEZONEFILE

        logmsg "Removing localtime file $LOCALTIMEFILE"
        run_command "rm -f $LOCALTIMEFILE"

        logmsg "Reconfiguring tzdata package"
        run_command "dpkg-reconfigure -f noninteractive tzdata"

        logmsg "Setting date/time via NTP"
        run_command "ntpdate pool.ntp.org"

        logmsg "Done setting timezone"
        return 1
    fi
}


###############################################################################
# 
###############################################################################
function random_password() {
    debug "${FUNCNAME[0]}(): entering"

    # generate a random password
    local PASS=$(date +%s | sha256sum | base64 | head -c 32 ; echo)

    # we have to echo it so it returns (gotta love shell)
    echo $PASS
}


###############################################################################
# 
###############################################################################
function create_autossh_user() {
    debug "${FUNCNAME[0]}(): entering"

    local PORT=$($DIRNAME/mactoport.py)
    local PASS=$(random_password)
    local CMD="useradd --shell /bin/bash --comment  autossh --create-home --password $PASS --uid $PORT autossh"

    run_command "$CMD"
    
    return 1
}


###############################################################################
# 
###############################################################################
function create_root_sshdir() {
    echo "${FUNCNAME[0]}(): entering"

    if [[ -d $HOME/.ssh ]]; then
        logmsg "Existing SSH directory exists, deleting and creating it"
        run_command "rm -fr $HOME/.ssh"
        run_command "mkdir $HOME/.ssh"
    else
        logmsg "No existing ssh directory, creating it"
        run_command "mkdir $HOME/.ssh"
    fi

    return 1

}


###############################################################################
# 
###############################################################################
function generate_root_sshkeys() {
    echo "${FUNCNAME[0]}(): entering"

    if [[ -f $HOME/.ssh/id_rsa ]]; then
        logmsg "Existing RSA keys exist, removing and creating them"
        run_command "rm -fr $HOME/.ssh/id_rsa*"
        RES=`ssh-keygen -b 2048 -t rsa -C root -f $HOME/.ssh/id_rsa -P ''`
    else
        logmsg "Existing RSA don't exist, creating them"
        RES=`ssh-keygen -b 2048 -t rsa -C root -f $HOME/.ssh/id_rsa -P ''`
    fi

    return 1
}


###############################################################################
# 
###############################################################################
function add_authorized_keys() {
    echo "${FUNCNAME[0]}(): entering"

    logmsg "Adding required authorized_keys"

    echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAv5jvwuGIpkvS/4uWHErclDbnwD7Py+Un78gUohQsknn/q4pByOynjexC/o0mN+Yw9S1oXgobM6zpZZNpM1mTaO0ipKadfnlmilmrcnavlzT531r0p+GQ0U+3m1dhE3lSYWsex0OWIsHxw+HUJEtGbzQkI/vc26Pz5lrEeOCOXuN+oUtHsant0ZhlQThz8ORODr1bNKvzgpdV1cVeRFQOugWLTRo9x2ePGeg0YvhwtvPEm9YJlksytlVl8X4NzBdnLeU9MWIJTAuEFli6IpajiB6a4wqD1Xqbrw6ud018x1mT3qyVwp0SCyK69l/8QuGV0pIShjrTdwKyRSczHxWAvQ== darren@yhlsecurity.com" > $HOME/.ssh/authorized_keys

    return 1
}


###############################################################################
# 
###############################################################################
function setup_vim() {
    echo "${FUNCNAME[0]}(): entering"

    mkdir -p ~/.vim/autoload ~/.vim/bundle 
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

    return 1
}


###############################################################################
# Take an action on a system service
###############################################################################
function service_action() {
    echo "${FUNCNAME[0]}(): entering, args: $*"

    # Make sure we got an action
    if [[ -z "$1" || -z "$2" ]]; then
        errmsg "Usage: ${FUNCNAME[0]} <action> <service>"
        return 1
    fi

    local ACTION="$1"
    local SERVICE="$2"

    case "$ACTION" in
        start) 
            start_service $SERVICE
            return 0
            ;;
        stop)
            stop_service $SERVICE
            return 0
            ;;
        restart)
            stop_service $SERVICE
            start_service $SERVICE
            return 0
            ;;
        *)
            echo $"Usage: $0 {start|stop|restart}" 
            return 1
    esac

}


###############################################################################
# Start a system service
###############################################################################
function start_service() {
    echo "${FUNCNAME[0]}(): entering"

    if [[ -z "$1" ]]; then
        errmsg "Invalid usage: pass a service to start"
        return 0
    else
        SERVICE="$1"
        logmsg "Starting service: $SERVICE"
        CMD="systemctl start $SERVICE"
        run_command "$CMD" 
        return 1
    fi
}


###############################################################################
# Stop a system service
###############################################################################
function stop_service() {
    echo "${FUNCNAME[0]}(): entering"

    if [[ -z "$1" ]]; then
        errmsg "Invalid usage: pass a service to stop"
        return 1
    else
        SERVICE="$1"
        logmsg "Stopping service: $SERVICE"
        CMD="systemctl stop $SERVICE"
        run_command "$CMD" 
        return 0
    fi
}


###############################################################################
# 
###############################################################################
function start_postgres() {
    echo "${FUNCNAME[0]}(): entering"

    service_action "start" "postgresql"
    return 0
}


###############################################################################
# 
###############################################################################
config_redis() {
    echo "${FUNCNAME[0]}(): entering"

    sed -i.BAK -e 's/^port 0/port 6379/' /etc/redis/redis.conf
    service_action "restart" "redis-server"
    return 0

}
