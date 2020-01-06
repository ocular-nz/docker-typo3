FROM composer as composer

FROM php:7.3-apache as server

COPY --from=composer /usr/bin/composer /usr/bin/composer

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
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install intl \
    && docker-php-ext-install zip \
    && docker-php-ext-install opcache \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install exif \
    && docker-php-ext-install pdo_mysql


COPY php/php.ini /usr/local/etc/php/php.ini
COPY php/conf.d/opcache.ini /usr/local/etc/php/conf.d/
COPY sites-available/000-default.conf /etc/apache2/sites-available/

RUN a2enmod rewrite
RUN a2enmod expires
