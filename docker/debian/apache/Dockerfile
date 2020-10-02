FROM php:7.4.10-fpm-buster
LABEL maintainer="Sam Huynh <samhwang2112.dev@gmail.com>"

# Install S6 Overlay
ARG S6_VERSION=2.0.0.1
RUN curl -LkSso /tmp/s6-overlay-amd64.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    rm /tmp/s6-overlay-amd64.tar.gz;

# Install Apache and other OS support for images.
RUN set -xe && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        apache2 && \
    apt-get install -y --no-install-recommends \
        libjpeg62-turbo-dev \
        libpng-dev \
        libfreetype6-dev \
        libzip-dev \
        libpq-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/*;

# Configure PHP Modules
RUN set -xe && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/server.key -out /etc/ssl/server.crt -subj "/C=AU/ST=VIC/L=Melbourne/O=Localhost/CN=Localhost"; \
    pear config-set php_ini "$PHP_INI_DIR" && \
    docker-php-ext-configure gd --with-jpeg=/usr/include --with-freetype=/usr/include && \
    docker-php-ext-install \
        pdo_mysql \
        mysqli \
        pdo_pgsql \
        pgsql \
        gd \
        zip && \
    pecl install mongodb redis && \
    pecl clear-cache && \        
    echo 'error_log = "/dev/stderr"' >> /usr/local/etc/php/php.ini && \
    echo 'access_log = "/dev/stdout"' >> /usr/local/etc/php/php.ini;

# Configure Apache
RUN set -xe && \
    a2enmod \
        macro \
        actions \
        proxy_fcgi \
        rewrite \
        ssl;

WORKDIR /var/www/html
COPY container .
RUN cp -r rootfs/services.d/php-fpm /etc/services.d/php-fpm && \
    cp -r rootfs/services.d/apache2 /etc/services.d/apache2 && \
    cp -r rootfs/apache2/ /etc/ && \
    chmod 6444 /var/log/apache2 && \
    chown -R www-data:www-data /var/www/html && \
    rm -rf rootfs/ /etc/apache2/conf.d;

# Running both php-fpm and Apache in foreground to intercept connections
STOPSIGNAL SIGTERM
EXPOSE 80 443
ENTRYPOINT ["docker-php-entrypoint", "/init"]