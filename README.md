# My Docker PHP Image

A general Docker PHP base setup for development.

## What does it have

- PHP 7.3
- Apache / NGINX server
- Supervisor (to manage PHP and the server)
- Debian / Alpine OS

> Does it fit Docker's guideline of one process per container ?

Sadly, no. PHP and its server pal (whether NGINX or Apache) gets
too coupled together that it still is a murky ground decision on
should they be separated. To me, I'm deciding on not opening a new
can of worms right now and stick with the less granular option.
This may change in the future.

## Supported tags

- `latest`, `7.3`, `7.3-apache`, `7.3-apache-debian`
- `7.3-apache-alpine`
- `7.3-nginx`, `7.3-nginx-debian`
- `7.3-nginx-alpine`

## Running the image

```bash
docker run -d --rm -p 80:80 -p 443:443 --name=testing samhwang/php
curl http://localhost
curl https://localhost/
docker stop testing
```

## Building the image locally

By default, if you don't specify a build arg and/or a Dockerfile, it
will resort to the default, which is Debian and Apache server.

```bash
git clone git@github.com:samhwang/docker-php-image.git
cd docker-php
docker build -f Dockerfile-[APACHE/nginx]-[DEBIAN/alpine] -t samhwang/php:latest .
```
