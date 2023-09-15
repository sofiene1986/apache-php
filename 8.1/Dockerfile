FROM php:8.1-apache
RUN apt-get clean && apt-get update && apt-get install --fix-missing wget apt-transport-https lsb-release ca-certificates gnupg2 -y
RUN apt-get install --fix-missing -y \
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
  libwebp-dev

# Create new web user for apache and grant sudo without password
RUN useradd web -d /var/www -g www-data -s /bin/bash
RUN usermod -aG sudo web
RUN echo 'web ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

###########################################################################
#                             PHP EXTENSIONS                              #
###########################################################################

#INSTALL mcrypt
RUN pecl install mcrypt && docker-php-ext-enable mcrypt

# Install APCu extension
RUN pecl install apcu

# Installation node.js

RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get install nodejs -y
COPY core/install-nodejs.sh /usr/local/bin/install-nodejs
RUN chown web:root /usr/local/bin/install-nodejs && chmod +x /usr/local/bin/install-nodejs

# Installation of Composer
RUN cd /usr/src && curl -sS http://getcomposer.org/installer | php
RUN cd /usr/src && mv composer.phar /usr/bin/composer

# Install xdebug.
RUN cd /tmp/ && wget http://xdebug.org/files/xdebug-3.1.0.tgz && tar -xvzf xdebug-3.1.0.tgz && cd xdebug-3.1.0/ && phpize && ./configure --enable-xdebug --with-php-config=/usr/local/bin/php-config && make && make install
RUN touch /usr/local/etc/php/php.ini &&\
    echo ';zend_extension=xdebug.so' >> /usr/local/etc/php/php.ini
RUN touch /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.mode=debug' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.start_with_request=yes' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.discover_client_host=0' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.client_port=9000' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.log=/tmp/php8-xdebug.log' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.client_host=hostname' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.idekey=PHPSTORM' >> /usr/local/etc/php/conf.d/xdebug.ini

    # Add xdebug function
COPY core/xdebug.sh /usr/local/bin/xdebug
RUN chown web:root /usr/local/bin/xdebug && chmod +x /usr/local/bin/xdebug

RUN docker-php-ext-install opcache pdo_mysql && docker-php-ext-install mysqli
RUN docker-php-ext-configure gd --with-jpeg --with-webp
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN apt-get install libonig-dev
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

# Install php-xhprof
RUN cd /tmp && git clone "https://github.com/tideways/php-xhprof-extension.git" && cd php-xhprof-extension && phpize && ./configure && make && make install
RUN touch /usr/local/etc/php/php.ini &&\
 echo ";extension=tideways_xhprof.so" >>  /usr/local/etc/php/php.ini
# Add xhprof function
COPY core/xhprof.sh /usr/local/bin/xhprof
RUN chown web:root /usr/local/bin/xhprof && chmod +x /usr/local/bin/xhprof

RUN apt-get install -y libmagickwand-dev mc cron && pecl install imagick && docker-php-ext-enable imagick
# Set and run a custom entrypoint

# Install PREDIS
RUN cd /tmp &&  wget https://pecl.php.net/get/redis-5.3.4.tgz && tar xf redis-5.3.4.tgz && cd redis-5.3.4 && phpize && ./configure && make install
RUN touch /usr/local/etc/php/conf.d/redis.ini &&\
 echo "extension=redis.so" >>  /usr/local/etc/php/conf.d/redis.ini

# INSTALL MEMCACHED
RUN pecl install memcached y
RUN touch /usr/local/etc/php/conf.d/redis.ini &&\
 echo "extension=memcached.so" >>  /usr/local/etc/php/conf.d/memcached.ini

RUN touch /usr/local/etc/php/php.ini &&\
 echo "max_execution_time=600" >>  /usr/local/etc/php/php.ini && \
 echo "max_input_time=600" >>  /usr/local/etc/php/php.ini && \
 echo "memory_limit=512M" >>  /usr/local/etc/php/php.ini && \
 echo "post_max_size=512M" >>  /usr/local/etc/php/php.ini && \
 echo "upload_max_filesize=512M" >>  /usr/local/etc/php/php.ini && \
 echo "upload_tmp_dir=/tmp" >>  /usr/local/etc/php/php.ini

# Apache2 config
COPY config/apache2.conf /etc/apache2
#COPY core/envvars /etc/apache2
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


RUN rm -rf /var/www/html && \
  mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html && \
  chown -R web:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html
RUN a2enmod rewrite expires ssl && service apache2 restart

# Our apache volume
VOLUME /var/www/html

# create directory for ssh keys
RUN mkdir /var/www/.ssh/ && mkdir /var/www/cache/ && chown -R web:www-data /var/www/ && chown -R web:root /var/www/.ssh && chmod -R 400 /var/www/.ssh

# Change owner tmp Folder
RUN chown -R web:www-data /tmp/
RUN chmod -R 777 /tmp/

# Installation drush
RUN cd /usr/local/src/ && mkdir drush12 && cd drush12 && composer require drush/drush:^12
RUN ln -s /usr/local/src/drush12/vendor/bin/drush /usr/local/bin/drush12
RUN cd /usr/local/src/ && mkdir drush11 && cd drush11 && composer require drush/drush:^11
RUN ln -s /usr/local/src/drush11/vendor/bin/drush /usr/local/bin/drush11
RUN cd /usr/local/src/ && mkdir drush10 && cd drush10 && composer require drush/drush:^10
RUN ln -s /usr/local/src/drush10/vendor/bin/drush /usr/local/bin/drush10
RUN cd /usr/local/src/ && mkdir drush9 && cd drush9 && composer require drush/drush:^9
RUN ln -s /usr/local/src/drush9/vendor/bin/drush /usr/local/bin/drush9

# Set timezone to Europe/Paris
RUN echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

RUN cd / && rm -rf /tmp/* /var/lib/apt/lists/*

# Expose 80,443 for apache + 9000 pour xdebug
EXPOSE 80 443 9000
# Add .bashrc config
COPY config/.bashrc /root/.bashrc

# Set and run a custom entrypoint
COPY core/docker-entrypoint.sh /
RUN chmod 777 /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
