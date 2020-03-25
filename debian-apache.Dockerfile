FROM php:7.4.4-fpm-buster
LABEL maintainer="Sam Huynh <samhwang2112.dev@gmail.com>"

# Install Apache and other OS support for images.
ARG S6_VERSION=1.22.1.0
RUN curl -LkSso /tmp/s6-overlay-amd64.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    rm /tmp/s6-overlay-amd64.tar.gz && \
    apt-get update && \
    apt-get install -y --no-install-recommends apache2 libjpeg62-turbo-dev libpng-dev libfreetype6-dev libzip-dev libpq-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/*;

# Configure Apache, PHP Modules and Supervisor
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/server.key -out /etc/ssl/server.crt -subj "/C=AU/ST=VIC/L=Melbourne/O=Localhost/CN=Localhost"; \
    docker-php-ext-configure gd --with-jpeg=/usr/include --with-freetype=/usr/include && \
    docker-php-ext-install pdo_mysql mysqli pdo_pgsql pgsql gd zip && \
    a2enmod macro actions proxy_fcgi rewrite ssl && \
    echo 'error_log = "/dev/stderr"' >> /usr/local/etc/php/php.ini && \
    echo 'access_log = "/dev/stdout"' >> /usr/local/etc/php/php.ini;

WORKDIR /var/www/html
COPY public ./public
COPY rootfs ./rootfs
RUN cp -r rootfs/services.d/php-fpm /etc/services.d/php-fpm && \
    cp -r rootfs/services.d/apache2 /etc/services.d/apache2 && \
    cp -r rootfs/apache2/ /etc/ && \
    chmod 6444 /var/log/apache2 && \
    chown -R www-data:www-data /var/www/html && \
    rm -rf rootfs/ /etc/apache2/conf.d;

# Running both php-fpm and Apache in foreground to intercept connections
STOPSIGNAL SIGTERM
EXPOSE 80 443
CMD ["/init"]