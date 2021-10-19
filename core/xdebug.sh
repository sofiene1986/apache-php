#!/bin/bash -e
set -e
status=$1
case $status in
  on)
      sudo sed -i 's/^;*\(.*xdebug\.so\)/\1/' /usr/local/etc/php/php.ini
      echo "xdebug on"
      echo "you need to restart container"
      ;;
  off)
      sudo sed -i 's/^\(.*xdebug\.so\)/;\1/' /usr/local/etc/php/php.ini
      echo "xdebug off"
      echo "you need to restart container"
      ;;
    *)
      echo "usage xdebug: on|off" 1>&2;
esac