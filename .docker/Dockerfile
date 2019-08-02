FROM php:7.3-fpm-buster
LABEL maintainer="Sam Huynh <samhwang2112.dev@gmail.com>"

WORKDIR /var/www/html
COPY . .
RUN bash .docker/install.sh

# Install composer and prestissimo for parallel download. Also install dependencies if needed.
COPY --from=composer /usr/bin/composer /usr/bin/composer
# Install Prestissimo for faster composer parallel download
# USER www-data
# RUN composer global require hirak/prestissimo
# RUN composer install --no-interaction --no-plugins --no-scripts --prefer-dist --ignore-platform-reqs

# Running both php-fpm and apache in foreground to intercept connections
STOPSIGNAL SIGTERM
EXPOSE 80 443
CMD php-fpm -D; apachectl -D FOREGROUND;