FROM php:7.3-fpm-buster
LABEL maintainer="Sam Huynh <samhwang2112.dev@gmail.com>"

ARG SERVER=apache2

# Install apache/ngix and other OS support for images.
RUN apt-get update && \
    apt-get install -y --no-install-recommends supervisor ${SERVER} libjpeg62-turbo-dev libpng-dev libfreetype6-dev libzip-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/*;

# Configure Apache/Nginx, PHP Modules and Supervisor
WORKDIR /var/www/html
COPY . .
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/server.key -out /etc/ssl/server.crt -subj "/C=AU/ST=VIC/L=Melbourne/O=Localhost/CN=Localhost"; \
    docker-php-ext-configure gd --with-gd --with-jpeg-dir=/usr/include --with-png-dir=/usr/include  --with-freetype-dir=/usr/include && \
    docker-php-ext-configure zip --with-libzip && \
    docker-php-ext-install pdo_mysql mysqli gd zip; \
    if [ "$SERVER" = "apache2" ]; then \
        a2enmod macro actions proxy_fcgi rewrite ssl; \
    fi; \
    echo 'error_log = "/dev/stderr"' >> /usr/local/etc/php/php.ini && \
    echo 'access_log = "/dev/stdout"' >> /usr/local/etc/php/php.ini && \
    cp rootfs/supervisor/supervisord.conf /etc/supervisor/supervisord.conf && \
    cp rootfs/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf && \
    cp rootfs/supervisor/conf.d/${SERVER}.conf /etc/supervisor/conf.d/${SERVER}.conf && \
    cp -r rootfs/${SERVER}/ /etc/ && \
    chmod 6444 /var/log/${SERVER} && \
    chown -R www-data:www-data /var/www/html && \
    rm -rf rootfs/ /etc/apache2/conf.d;

# Running both php-fpm and apache in foreground to intercept connections
STOPSIGNAL SIGTERM
EXPOSE 80 443
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]