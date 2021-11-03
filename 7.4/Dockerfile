FROM php:7.4.12-apache

RUN apt-get clean && apt-get update && apt-get install --fix-missing wget apt-transport-https lsb-release ca-certificates gnupg2 -y
RUN apt-get clean && apt-get update && apt-get install --fix-missing -y \
  ruby-dev \
  rubygems \
  imagemagick \
  graphviz \
  memcached \
  libmemcached-tools \
  libmemcached-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libxml2-dev \
  libxslt1-dev \
  default-mysql-client \
  sudo \
  git \
  vim \
  zip \
  wget \
  htop \
  iputils-ping \
  dnsutils \
  telnet \
  linux-libc-dev \
  libyaml-dev \
  libpng-dev \
  zlib1g-dev \
  libzip-dev \
  libicu-dev \
  libpq-dev \
  bash-completion \
  libldap2-dev \
  libssl-dev \
  libonig-dev \
  libwebp-dev

RUN pecl install mcrypt-1.0.3 && \
  docker-php-ext-enable mcrypt

# Create new web user for apache and grant sudo without password
RUN useradd web -d /var/www -g www-data -s /bin/bash
RUN usermod -aG sudo web
RUN echo 'web ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install APCu extension
RUN pecl install apcu

# Installation node.js
ENV NODEJS_VERSION 12.x
RUN curl -sL https://deb.nodesource.com/setup_$NODEJS_VERSION | bash -
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install -y nodejs

# Installation of Gulp
RUN npm install -g gulp

# Installation of Composer
RUN cd /usr/src && curl -sS http://getcomposer.org/installer | php
RUN cd /usr/src && mv composer.phar /usr/bin/composer

# Install xdebug.
RUN cd /tmp/ && wget http://xdebug.org/files/xdebug-2.9.0.tgz && tar -xvzf xdebug-2.9.0.tgz && cd xdebug-2.9.0/ && phpize && ./configure --enable-xdebug --with-php-config=/usr/local/bin/php-config && make && make install
RUN cd /tmp/xdebug-2.9.0 && cp modules/xdebug.so /usr/local/lib/php/extensions/
RUN touch /usr/local/etc/php/php.ini &&\
    echo 'zend_extension=/usr/local/lib/php/extensions/xdebug.so' >> /usr/local/etc/php/php.ini
RUN touch /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.remote_enable=1' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.remote_autostart=0' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.remote_connect_back=0' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.remote_port=9000' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.remote_log=/tmp/php7-xdebug.log' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.remote_host=hostname' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.idekey=PHPSTORM' >> /usr/local/etc/php/conf.d/xdebug.ini

# Apache2 config
COPY config/apache2.conf /etc/apache2
COPY core/envvars /etc/apache2
COPY core/other-vhosts-access-log.conf /etc/apache2/conf-enabled/
RUN rm /etc/apache2/sites-enabled/000-default.conf

# create directory for ssl certificats
RUN mkdir /var/www/ssl-certificat
COPY config/ssl/* /var/www/ssl-certificat/
RUN chown -R web:www-data /var/www/ssl-certificat/
RUN chmod -R 777 /var/www/ssl-certificat/

#added for AH00111 Error
ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2

RUN docker-php-ext-install opcache pdo_mysql && docker-php-ext-install mysqli
RUN docker-php-ext-configure gd --with-jpeg --with-webp
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-install gd mbstring zip soap xsl calendar intl exif pgsql pdo_pgsql ftp bcmath ldap

# Custom Opcache
RUN ( \
  echo "opcache.memory_consumption=128"; \
  echo "opcache.interned_strings_buffer=8"; \
  echo "opcache.max_accelerated_files=20000"; \
  echo "opcache.revalidate_freq=5"; \
  echo "opcache.fast_shutdown=1"; \
  echo "opcache.enable_cli=1"; \
  ) >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

RUN rm -rf /var/www/html && \
  mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html && \
  chown -R web:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html
RUN a2enmod rewrite expires ssl && service apache2 restart

# Installation of PHP_CodeSniffer with Drupal coding standards.
# See https://www.drupal.org/node/1419988#coder-composer
RUN composer global require drupal/coder
RUN ln -s ~/.composer/vendor/bin/phpcs /usr/local/bin
RUN ln -s ~/.composer/vendor/bin/phpcbf /usr/local/bin
RUN phpcs --config-set installed_paths ~/.composer/vendor/drupal/coder/coder_sniffer

# Our apache volume
VOLUME /var/www/html

# create directory for ssh keys
RUN mkdir /var/www/.ssh/
RUN mkdir /var/www/cache/
RUN chown -R web:www-data /var/www/


RUN rm -fr /tmp/*

# Change owner tmp Folder
RUN chown -R web:www-data /tmp/
RUN chmod -R 777 /tmp/

# Installation drush
RUN cd /usr/local/src/ && mkdir drush && cd drush && composer require drush/drush
RUN ln -s /usr/local/src/drush/vendor/bin/drush /usr/local/bin/drush

# Set timezone to Europe/Paris
RUN echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# Install php-xhprof
RUN cd /tmp && git clone "https://github.com/tideways/php-xhprof-extension.git" && cd php-xhprof-extension && phpize && ./configure && make && make install
RUN cd / && rm -rf /tmp/*

# Install Cron
RUN apt-get update && apt-get install -y cron

# Expose 80,443 for apache + 9000 pour xdebug
EXPOSE 80 443 9000

RUN touch /usr/local/etc/php/php.ini &&\
 echo "extension=tideways_xhprof.so" >>  /usr/local/etc/php/php.ini

# Add xdebug function
COPY core/xdebug.sh /usr/local/bin/xdebug
RUN chown web:root /usr/local/bin/xdebug && chmod +x /usr/local/bin/xdebug

# Add xhprof function
COPY core/xhprof.sh /usr/local/bin/xhprof
RUN chown web:root /usr/local/bin/xhprof && chmod +x /usr/local/bin/xhprof

# Add .bashrc config
COPY config/.bashrc /root/.bashrc
RUN chown www-data:www-data /root/.bashrc

# Set and run a custom entrypoint
COPY core/docker-entrypoint.sh /
RUN chmod 777 /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
