FROM composer AS composer

FROM php:7.4-fpm

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY conf.d/custom.ini /usr/local/etc/php/conf.d/

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        libicu-dev \
        imagemagick \
        zip \
        git \
        libmagickwand-dev \
        sqlite3 \
        memcached \
        mariadb-client \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install intl \
    && docker-php-ext-install zip \
    && docker-php-ext-install opcache \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install exif \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install pcntl
