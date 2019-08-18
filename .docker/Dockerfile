# Install composer dependencies
FROM composer:1.9 as vendor

COPY composer.json composer.json

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist \
    --ignore-platform-reqs

FROM php:7.3-fpm-buster
LABEL maintainer="Sam Huynh <samhwang2112.dev@gmail.com>"

ARG SERVER=apache2
ARG ENVIRONMENT=development
ARG XDEBUG_ENABLE=true
ENV SSLKey=".docker/ssl/server.key"
ENV SSLCert=".docker/ssl/server.crt"

# Enable PHP modules
WORKDIR /var/www/html
COPY . .

# Install apache/ngix and other OS support for images.
RUN apt-get update && \
    apt-get install -y --no-install-recommends supervisor ${SERVER} libjpeg62-turbo-dev libpng-dev libfreetype6-dev libzip-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/man/* /usr/share/doc/*;

# Dev environment config: MailHog SMTP, SSL Keys and XDebug
RUN if [ "$ENVIRONMENT" = 'development' ]; then \
        curl -o /usr/bin/mhsendmail 'https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64' && \
        chmod 0755 /usr/bin/mhsendmail && \
        echo 'sendmail_path = "/usr/bin/mhsendmail --smtp-addr=mailhog:1025"' > /usr/local/etc/php/php.ini; \
        if [ ! -e "$SSLKey" ] && [ ! -e "$SSLCert" ]; then \
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout .docker/ssl/server.key -out .docker/ssl/server.crt -subj "/C=AU/ST=VIC/L=Melbourne/O=Localhost/CN=Localhost"; \
        fi; \
        if [ "$XDEBUG_ENABLE" = true ]; then \
            pecl install xdebug && \
            docker-php-ext-enable xdebug && \
            echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
            echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
            echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
            echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
        fi; \
    fi;

# Configure Apache/Nginx, PHP Modules and Supervisor
RUN cp .docker/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf && \
    cp .docker/supervisor/conf.d/${SERVER}.conf /etc/supervisor/conf.d/${SERVER}.conf && \
    cp -r .docker/${SERVER}/ /etc/ && \
    cp -r .docker/ssl/ /etc/ && \
    rm -rf .docker/ && \
    chmod 6444 /var/log/${SERVER} && \
    chown -R www-data:www-data /var/www/html && \
    docker-php-ext-configure gd --with-gd --with-jpeg-dir=/usr/include --with-png-dir=/usr/include  --with-freetype-dir=/usr/include && \
    docker-php-ext-configure zip --with-libzip && \
    docker-php-ext-install pdo_mysql mysqli gd zip; \ 
    if [ "$SERVER" = "apache2" ]; then \
        a2enmod macro actions proxy_fcgi rewrite ssl; \
    fi

COPY --from=vendor /app/vendor/ ./vendor/

# Running both php-fpm and apache in foreground to intercept connections
STOPSIGNAL SIGTERM
EXPOSE 80 443
CMD supervisord -n -c /etc/supervisor/supervisord.conf;
