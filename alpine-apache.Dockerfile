FROM php:7.4.2-fpm-alpine3.11
LABEL maintainer="Sam Huynh <samhwang2112.dev@gmail.com>"

# Install apache and other OS support for images.
RUN apk update && \
    apk add --no-cache bash apache2 apache2-proxy apache2-ssl supervisor libjpeg-turbo-dev libpng-dev freetype-dev libzip-dev postgresql-dev;

# Configure Apache, PHP Modules and Supervisor
WORKDIR /var/www/html
COPY public ./public
COPY rootfs ./rootfs
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/server.key -out /etc/ssl/server.crt -subj "/C=AU/ST=VIC/L=Melbourne/O=Localhost/CN=Localhost"; \
    docker-php-ext-configure gd --with-jpeg=/usr/include --with-freetype=/usr/include && \
    docker-php-ext-install pdo_mysql mysqli pdo_pgsql pgsql gd zip; \
    sed -i 's@^#LoadModule actions_module modules/mod_actions\.so@LoadModule actions_module modules/mod_actions.so@' /etc/apache2/httpd.conf && \
    sed -i 's@^#LoadModule macro_module modules/mod_macro\.so@LoadModule macro_module modules/mod_macro.so@' /etc/apache2/httpd.conf && \
    sed -i 's@^#LoadModule rewrite_module modules/mod_rewrite\.so@LoadModule rewrite_module modules/mod_rewrite.so@' /etc/apache2/httpd.conf && \
    sed -ri -e 's!DocumentRoot "/var/www/localhost/htdocs"!DocumentRoot "/var/www/html/public/"!g' /etc/apache2/httpd.conf && \
    echo 'Include /etc/apache2/sites-enabled/*.conf' >> /etc/apache2/httpd.conf && \
    ln -s /usr/sbin/httpd /usr/sbin/apachectl && \
    echo 'error_log = "/dev/stderr"' >> /usr/local/etc/php/php.ini && \
    echo 'access_log = "/dev/stdout"' >> /usr/local/etc/php/php.ini && \
    mkdir /etc/supervisor && mkdir /etc/supervisor/conf.d && \
    cp rootfs/supervisor/supervisord.conf /etc/supervisor/supervisord.conf && \
    cp rootfs/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf && \
    cp rootfs/supervisor/conf.d/apache2.conf /etc/supervisor/conf.d/apache2.conf && \
    cp -r rootfs/apache2/ /etc/ && \
    chmod -R 775 /var/www && \
    chown -R www-data:www-data /var/www/html && \
    rm -rf rootfs/ /var/cache/apk/*;

# Running both php-fpm and apache in foreground to intercept connections
STOPSIGNAL SIGTERM
EXPOSE 80 443
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]