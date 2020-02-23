FROM php:7.4.2-fpm-buster
LABEL maintainer="Sam Huynh <samhwang2112.dev@gmail.com>"

# Install NGINX and other OS support for images.
RUN apt-get update && \
    apt-get install -y --no-install-recommends supervisor nginx libjpeg62-turbo-dev libpng-dev libfreetype6-dev libzip-dev libpq-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/*;

# Configure NGINX, PHP Modules and Supervisor
WORKDIR /var/www/html
COPY public ./public
COPY rootfs ./rootfs
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/server.key -out /etc/ssl/server.crt -subj "/C=AU/ST=VIC/L=Melbourne/O=Localhost/CN=Localhost"; \
    docker-php-ext-configure gd --with-jpeg=/usr/include --with-freetype=/usr/include && \
    docker-php-ext-install pdo_mysql mysqli pdo_pgsql pgsql gd zip; \
    echo 'error_log = "/dev/stderr"' >> /usr/local/etc/php/php.ini && \
    echo 'access_log = "/dev/stdout"' >> /usr/local/etc/php/php.ini && \
    cp rootfs/supervisor/supervisord.conf /etc/supervisor/supervisord.conf && \
    cp rootfs/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf && \
    cp rootfs/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf && \
    cp -r rootfs/nginx/ /etc/ && \
    mv /etc/nginx/conf.d/default.conf /etc/nginx/sites-enabled/default && \
    chmod 6444 /var/log/nginx && \
    chown -R www-data:www-data /var/www/html && \
    rm -rf rootfs/ /etc/apache2/conf.d;

# Running both php-fpm and NGINX in foreground to intercept connections
STOPSIGNAL SIGTERM
EXPOSE 80 443
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]