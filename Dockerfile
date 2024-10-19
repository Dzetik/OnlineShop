FROM composer:2.5 AS composer
FROM php:8.2.1-fpm

ARG APP_ENV=dev
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1
ENV TZ=Europe/Moscow
ENV LANG en_US.UTF-8

# php
RUN apt-get update \
    && apt-get -y --no-install-recommends install libpq-dev \
            libicu-dev \
            libzip-dev \
            librabbitmq-dev \
            zip unzip \
            nano \
            libfreetype6-dev \
            libjpeg62-turbo-dev \
            libpng-dev \
            libc-client-dev \
            libkrb5-dev \
            locales \
            wget \
            libonig-dev \
    && docker-php-ext-install pdo pgsql pdo_pgsql zip intl gd bcmath sockets mbstring \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
    && docker-php-ext-enable gd \
    && pecl install amqp \
    && docker-php-ext-enable amqp

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=$LANG \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && echo 'alias ll="ls -la"' >> ~/.bashrc

# Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Node.js & Yarn
#RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh \
#    && bash nodesource_setup.sh \
#    && apt-get install nodejs -y \
#    && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
#    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
#    && apt-get update && apt-get install yarn \
#    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc


# Project
WORKDIR /var/www/app
COPY ./ /var/www/app
COPY ./deployment/php.ini /usr/local/etc/php/custom.d/php.ini

#RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
#    && mkdir -p /var/www/app/var/cache \
#    && mkdir -p /var/www/app/var/log \
#    && rm -rf /var/www/app/var/cache/* \
#    && composer install \
#    && php bin/console assets:install \
#    && php -d memory_limit=256M bin/console cache:clear \
#    && php bin/console cache:warm \
#    && chmod -R 777 /var/www/app/var


ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["php-fpm"]
