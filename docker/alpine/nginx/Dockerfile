FROM php:8.0.8-fpm-alpine3.13
LABEL maintainer="Sam Huynh <samhwang2112.dev@gmail.com>"

# Install S6 Overlay
ARG S6_VERSION=2.1.0.2
RUN curl -LkSso /tmp/s6-overlay-amd64.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    rm /tmp/s6-overlay-amd64.tar.gz;

# Install NGINX and other OS support for images.
RUN set -xe && \
    apk update && \
    apk add --no-cache \
        nginx && \
    apk add --no-cache \
        bash \
        libjpeg-turbo-dev \
        libpng-dev \
        freetype-dev \
        libzip-dev \
        postgresql-dev && \
    rm -rf /var/cache/apk/*;

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
    apk add --no-cache --virtual build-deps ${PHPIZE_DEPS} && \
    pecl install mongodb redis && \
    pecl clear-cache && \
    apk del build-deps && \
    docker-php-ext-enable mongodb redis && \
    echo 'error_log = "/dev/stderr"' >> /usr/local/etc/php/php.ini && \
    echo 'access_log = "/dev/stdout"' >> /usr/local/etc/php/php.ini;

# Add NGINX run folder
RUN mkdir -p /run/nginx

WORKDIR /var/www/html
COPY container .
RUN set -xe && \
    cp -r rootfs/services.d/php-fpm /etc/services.d/php-fpm && \
    cp -r rootfs/services.d/nginx /etc/services.d/nginx && \
    cp -r rootfs/nginx/ /etc/ && \
    rm /etc/nginx/http.d/default.conf && \
    mv /etc/nginx/sites-enabled/default.conf /etc/nginx/http.d/default.conf && \
    chmod -R 775 /var/www && \
    chown -R www-data:www-data /var/www/html && \
    rm -rf rootfs/;

# Running both php-fpm and NGINX in foreground to intercept connections
STOPSIGNAL SIGTERM
EXPOSE 80 443
ENTRYPOINT ["docker-php-entrypoint", "/init"]
