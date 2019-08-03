FROM php:7.3-fpm-buster
LABEL maintainer="Sam Huynh <samhwang2112.dev@gmail.com>"

WORKDIR /var/www/html
COPY . .
RUN bash .docker/install.sh

# Running both php-fpm and apache in foreground to intercept connections
STOPSIGNAL SIGTERM
EXPOSE 80 443
CMD php-fpm -D; apachectl -D FOREGROUND;