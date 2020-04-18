FROM php:7.4.5-fpm-alpine3.11
LABEL maintainer="Sam Huynh <samhwang2112.dev@gmail.com>"

# Install NGINX and other OS support for images.
ARG S6_VERSION=1.22.1.0
RUN curl -LkSso /tmp/s6-overlay-amd64.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    rm /tmp/s6-overlay-amd64.tar.gz && \
    apk update && \
    apk add --no-cache bash nginx libjpeg-turbo-dev libpng-dev freetype-dev libzip-dev postgresql-dev && \
    rm -rf /var/cache/apk/*;

# Configure NGINX, PHP Modules and Supervisor
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/server.key -out /etc/ssl/server.crt -subj "/C=AU/ST=VIC/L=Melbourne/O=Localhost/CN=Localhost"; \
    docker-php-ext-configure gd --with-jpeg=/usr/include --with-freetype=/usr/include && \
    docker-php-ext-install pdo_mysql mysqli pdo_pgsql pgsql gd zip; \
    mkdir -p /run/nginx && \
    echo 'error_log = "/dev/stderr"' >> /usr/local/etc/php/php.ini && \
    echo 'access_log = "/dev/stdout"' >> /usr/local/etc/php/php.ini;

WORKDIR /var/www/html
COPY container .
RUN cp -r rootfs/services.d/php-fpm /etc/services.d/ && \
    cp -r rootfs/services.d/nginx /etc/services.d/ && \
    cp -r rootfs/nginx/ /etc/ && \
    chmod -R 775 /var/www && \
    chown -R www-data:www-data /var/www/html && \
    rm -rf rootfs/;

# Running both php-fpm and NGINX in foreground to intercept connections
STOPSIGNAL SIGTERM
EXPOSE 80 443
ENTRYPOINT ["docker-php-entrypoint", "/init"]
