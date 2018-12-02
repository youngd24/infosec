###############################################################################
#
#
#
###############################################################################

# Needed to run from systemd at startup
DEBIAN_FRONTEND="noninteractive"; export DEBIAN_FRONTEND
DEBUG="true"

###############################################################################

# Locations
LOGDIR="$DIRNAME/../log"
LIBDIR="$DIRNAME/../lib"
CRONTABDIR="/var/spool/cron/crontabs"
TMPLDIR="$DIRNAME/../tmpl"
BACKUPDIR="/backup"

LOGFILE="$DIRNAME/../log/firstboot.log"
FIRSTBOOTFILE="/.firstboot"

# Packages to install
APT_PACKAGES="python-pip \
              python-virtualenv \
              htop \
              redis \
              lynx \
              autossh \
              glances \
              sshfs \
              tor \
              proxychains \
              software-properties-common \
              nikto \
              wpscan \
              sslscan \
              openvas \
              postgresql \
              kali-linux-top10 \
              libxml2-utils \
              default-libmysqlclient-dev \
              net-tools"
PIP_PACKAGES="docutils netifaces redis suds psutil Celery mysql-python"

# Host name setting locations
HOSTNAME=""
HOSTSFILE="/etc/hosts"
HOSTNAMEFILE="/etc/hostname"


# Time/date stuff
LOCALTIMEFILE="/etc/localtime"
TIMEZONEFILE="/etc/timezone"
TIMEZONE="America/Chicago"


###############################################################################

# Various things we can toggle on and off

RUN_SSHD_CONFIG="true"
RUN_GENERATE_SSHD_HOSTKEYS="true"
RUN_CREATE_BACKUP_DIR="true"
RUN_APT_UPDATE="false"
RUN_APT_PACKAGES="false"
RUN_PIP_PACKAGES="false"
RUN_SET_HOSTNAME="true"
RUN_TOUCH_FIRSTBOOTFILE="true"
RUN_SET_TIMEZONE="true"

