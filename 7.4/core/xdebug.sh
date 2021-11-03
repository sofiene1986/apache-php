#!/bin/bash -e
set -e
status=$1
case $status in
  on)
      sudo sed -i 's/^;*\(.*xdebug\.so\)/\1/' /usr/local/etc/php/php.ini
      echo "xdebug on"
      sudo service apache2 reload > /dev/null
      ;;
  off)
      sudo sed -i 's/^\(.*xdebug\.so\)/;\1/' /usr/local/etc/php/php.ini
      echo "xdebug off"
      sudo service apache2 reload > /dev/null
      ;;
    *)
      echo "usage xdebug: on|off" 1>&2;
esac