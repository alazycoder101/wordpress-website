# https://github.com/cicnavi/dockers/blob/master/dap/80/Dockerfile
ARG PHP_VERSION=8.0.3
FROM php:${PHP_VERSION}-apache

# Use the default development php.ini configuration
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends \
    zip git libpng-dev libpq-dev libzip-dev libmemcached-dev  \
    && docker-php-ext-install gd opcache pdo pdo_pgsql pgsql \
    && pecl install xdebug-3.1.3 \
    && pecl install memcached-3.1.5 \
    && docker-php-ext-enable xdebug memcached pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install composer and update path
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
COPY composer.json .
RUN composer install

# Copy custom config to PHP config dir.
COPY config/debug.ini "$PHP_INI_DIR/conf.d/"
