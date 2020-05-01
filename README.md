# My Docker PHP Image

![LICENSE](https://img.shields.io/github/license/samhwang/docker-php-image?style=for-the-badge)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/samhwang/php?style=for-the-badge)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/samhwang/php?style=for-the-badge)
![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=samhwang/docker-php-image)

A general Docker PHP base setup for development.

## What does it have

- PHP 7.4
  - Filesystem supports: PNG, JPEG, ZIP, Freetype, PQ, GD
  - DB support: MySQL, PostgreSQL
- Apache / NGINX server
- S6 (to supervise PHP and the server)
- Debian / Alpine OS

## Does it fit Docker's guideline of one process per container

Sadly, no. PHP and its server pal (whether NGINX or Apache) gets
too coupled together that it gets way too granular and too much of
a hassle to split them up. I have since adopted the just-containers'
interpretation of "The Docker Way".

More explanation can be found on their [s6-overlay](https://github.com/just-containers/s6-overlay#the-docker-way)
repo.

## Supported tags

- `latest`, `7.4`, `7.4-apache`
- `7.4-alpine`,`7.4-apache-alpine`
- `7.4-nginx`
- `7.4-nginx-alpine`

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
docker build -f docker/[debian/alpine]/[apache/nginx]/Dockerfile -t samhwang/php .
```
