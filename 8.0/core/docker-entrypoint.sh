#!/bin/bash -e
set -e

# Apache2 custom servername, alias and documentroot
sed -i "s/APACHESERVERNAME/$SERVERNAME/g" /etc/apache2/apache2.conf
sed -i "s/APACHESERVERALIAS/$SERVERALIAS/g" /etc/apache2/apache2.conf
sed -i "s/MYDOCUMENTROOT/$DOCUMENTROOT/g" /etc/apache2/apache2.conf

# Set the apache user and group to match the host user.
# This script will change the web UID/GID in the container from to 999 (default) to the UID/GID of the host user, if the current host user is not root.
OWNER=$(stat -c '%u' /var/www/html)
GROUP=$(stat -c '%g' /var/www/html)
USERNAME=web
[ -e "/etc/debian_version" ] || USERNAME=apache
if [ "$OWNER" != "0" ]; then
  usermod -o -u $OWNER $USERNAME
  groupmod -o -g $GROUP www-data
fi
if [ -n "$FILES_PATH" ]; then
  if [ -d "$FILES_PATH" ]; then
    echo "$FILES_PATH already exist"
  else
    echo "Create $FILES_PATH ..."
    mkdir $FILES_PATH
  fi
  OWNER=$(stat -c '%u' "$FILES_PATH")
  GROUP=$(stat -c '%g' "$FILES_PATH")
  if [ "$OWNER" != "0" ]; then
    usermod -o -u $OWNER $USERNAME
    groupmod -o -g $GROUP www-data
    chmod 777 $FILES_PATH
  fi
fi
cp /var/www/ssh/* /var/www/.ssh/
/etc/init.d/cron start
# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

case $USE_YARN in
  TRUE)
      apt-get update
      npm install --global yarn
      rm -rf /var/lib/apt/lists/*n
      ;;
esac
# Start Apache in foreground
/usr/sbin/apache2 -DFOREGROUND
