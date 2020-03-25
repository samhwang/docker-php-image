FROM php:7.4.4-fpm-alpine3.11
LABEL maintainer="Sam Huynh <samhwang2112.dev@gmail.com>"

# Install NGINX and other OS support for images.
RUN apk update && \
    apk add --no-cache bash nginx supervisor libjpeg-turbo-dev libpng-dev freetype-dev libzip-dev postgresql-dev;

# Configure NGINX, PHP Modules and Supervisor
WORKDIR /var/www/html
COPY public ./public
COPY rootfs ./rootfs
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/server.key -out /etc/ssl/server.crt -subj "/C=AU/ST=VIC/L=Melbourne/O=Localhost/CN=Localhost"; \
    docker-php-ext-configure gd --with-jpeg=/usr/include --with-freetype=/usr/include && \
    docker-php-ext-install pdo_mysql mysqli pdo_pgsql pgsql gd zip; \
    mkdir -p /run/nginx && \
    echo 'error_log = "/dev/stderr"' >> /usr/local/etc/php/php.ini && \
    echo 'access_log = "/dev/stdout"' >> /usr/local/etc/php/php.ini && \
    mkdir /etc/supervisor && mkdir /etc/supervisor/conf.d && \
    cp rootfs/supervisor/supervisord.conf /etc/supervisor/supervisord.conf && \
    cp rootfs/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf && \
    cp rootfs/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf && \
    cp -r rootfs/nginx/ /etc/ && \
    chmod -R 775 /var/www && \
    chown -R www-data:www-data /var/www/html && \
    rm -rf rootfs/ /var/cache/apk/*;

# Running both php-fpm and NGINX in foreground to intercept connections
STOPSIGNAL SIGTERM
EXPOSE 80 443
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
