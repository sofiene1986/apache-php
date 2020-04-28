FROM php:5.6-apache
RUN apt-get update && apt-get install -y --no-install-recommends libjpeg-dev libpng-dev libpq-dev
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr;
RUN docker-php-ext-install -j "$(nproc)" gd pdo_mysql pdo_pgsql zip

# Install Postgresql Repo & binaries
RUN apt update \
    && apt install wget gnupg2 -y \
    && wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" | tee /etc/apt/sources.list.d/postgresql.list \
    && apt update && apt install postgresql-client-10 -y

#Install composer
RUN cd /usr/src && curl -sS http://getcomposer.org/installer | php
RUN cd /usr/src && mv composer.phar /usr/bin/composer
RUN apt-get clean && apt-get update && apt-get install --fix-missing -y memcached libmemcached-tools libmemcached-dev sudo git vim wget iputils-ping dnsutils telnet libssl-dev

# Create new web user for apache and grant sudo without password
RUN useradd web -d /var/www -g www-data -s /bin/bash
RUN usermod -aG sudo web
RUN echo 'web ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# create directory for ssh keys
RUN mkdir /var/www/.ssh/
RUN mkdir /var/www/cache/
RUN chown -R web:www-data /var/www/

RUN rm -rf /var/www/html && \
  mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html && \
  chown -R web:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html

RUN a2enmod rewrite ssl && service apache2 restart


# Add .bashrc config
COPY config/.bashrc /root/.bashrc
RUN chown www-data:www-data /root/.bashrc

WORKDIR /var/www/html
VOLUME /var/www/html

# Expose 80,443 for apache + 9000 pour xdebug
EXPOSE 80 443 9000

# Apache2 config
COPY config/apache2.conf /etc/apache2
#added for AH00111 Error
ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2

RUN chmod -R 777 /var/www/html
# Set and run a custom entrypoint
COPY core/docker-entrypoint.sh /
RUN chmod 777 /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]