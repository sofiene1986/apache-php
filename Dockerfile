FROM php:5.6-apache
# install the PHP extensions we need
RUN set -ex; \
        \
        if command -v a2enmod; then \
                a2enmod rewrite; \
        fi; \
        \
        savedAptMark="$(apt-mark showmanual)"; \
        \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                libjpeg-dev \
                libpng-dev \
                libpq-dev \
        ; \
        \
        docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
        docker-php-ext-install -j "$(nproc)" \
                gd \
                opcache \
                pdo_mysql \
                pdo_pgsql \
                zip \
        ; \
        \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
        apt-mark auto '.*' > /dev/null; \
        apt-mark manual $savedAptMark; \
        ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
                | awk '/=>/ { print $3 }' \
                | sort -u \
                | xargs -r dpkg-query -S \
                | cut -d: -f1 \
                | sort -u \
                | xargs -rt apt-mark manual; \
        \
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
        rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
                echo 'opcache.memory_consumption=128'; \
                echo 'opcache.interned_strings_buffer=8'; \
                echo 'opcache.max_accelerated_files=4000'; \
                echo 'opcache.revalidate_freq=60'; \
                echo 'opcache.fast_shutdown=1'; \
                echo 'opcache.enable_cli=1'; \
        } > /usr/local/etc/php/conf.d/opcache-recommended.ini

WORKDIR /var/www/html

# Install Postgresql Repo & binaries
RUN apt update \
    && apt install wget gnupg2 -y \
    && wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" | tee /etc/apt/sources.list.d/postgresql.list \
    && apt update && apt install postgresql-client-10 -y

# Update system and install needed packages.
RUN apt update \
    && apt install git bsd-mailx ssmtp vim mlocate -y \
    && rm -rf /var/lib/apt/lists/* \
    && find /usr/share/doc -depth -type f | xargs rm -rf || true \
    && find /usr/share/doc -empty|xargs rmdir || true

RUN cd /usr/src && curl -sS http://getcomposer.org/installer | php
RUN cd /usr/src && mv composer.phar /usr/bin/composer

# Install Imagick
RUN apt update \
    && apt install libmagickwand-dev imagemagick --no-install-recommends -y \
    && pecl install imagick \
    && docker-php-ext-enable imagick
# Create new web user for apache and grant sudo without password
RUN useradd web -d /var/www -g www-data -s /bin/bash
RUN usermod -aG sudo web
RUN echo 'web ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN chown -R web:www-data /var/www/html

EXPOSE 80 443 9000

