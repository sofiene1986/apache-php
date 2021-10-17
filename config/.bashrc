alias ll='ls -al'
function xdebug() {
  xdb_usage() { echo "usage xdebug: on|off" 1>&2; }

  case "$1" in
    on)
        sudo sed -i 's/^;*\(.*xdebug\.so\)/\1/' /usr/local/etc/php/php.ini
        sudo service apache2 reload > /dev/null
        echo "xdebug on";
        ;;
    off)

        sudo sed -i 's/^\(.*xdebug\.so\)/;\1/' /usr/local/etc/php/php.ini
        sudo service apache2 reload > /dev/null
        echo "xdebug off";
        ;;
    *)
        xdb_usage
  esac
}
function xhprof() {
  xhprof_usage() { echo "usage xhprof: on|off" 1>&2; }

  case "$1" in
    on)
        sudo sed -i 's/^;*\(.*tideways_xhprof\.so\)/\1/' /usr/local/etc/php/php.ini
        sudo service apache2 reload > /dev/null
        echo "xdebug on";
        ;;
    off)

        sudo sed -i 's/^\(.*tideways_xhprof\.so\)/;\1/' /usr/local/etc/php/php.ini
        sudo service apache2 reload > /dev/null
        echo "xhprof off";
        ;;
    *)
        xhprof_usage
  esac
}
alias drush='sudo -u www-data drush'
alias svn='sudo -u www-data svn'
alias git='sudo -u www-data git'
alias wget='sudo -u www-data wget'
alias ssh='sudo -u www-data ssh'
su - web