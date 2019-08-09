# Docker PHP Environment

A general Docker PHP base setup for development.

## What does it have

This image consists of PHP-FPM 7.3 and Apache 2.4 running
on a Debian Buster base. It also integrates mailhog for
development environment so it does not spam people emails
excessively.

> But does it fit Docker's guideline of one process per
> container ?

Sadly, no. To follow Docker's guidelines to the point means
I have to split the PHP image into 2 separate images, which
may sound ok, but it gets too granular at that point, in my
honest opinion. This may change in the future.

## Running the image

```bash
docker run -d --rm -p 80:80 -p 443:443 --name=testing samhwang/php
curl http://localhost
curl https://localhost/
docker stop testing
```

## Building the image locally

By default in development environment, upon buildin the image,
it will check if there already exists a pair of SSL key files
and certificate. If not, it will generate one. But if you want
to generate your own, you can run:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout .docker/apache/ssl/server.key -out .docker/apache2/ssl/server.crt
```

```bash
git clone git@github.com:samhwang/docker-php.git
cd docker-php
docker build -f .docker/Dockerfile -t samhwang/php:latest .
```

You can also add build arguments for environment such as
`staging` and `production` to prevent mailhog being installed.
After that, remove the `mailhog` link in the `www01` container,
and remove the `mailhog` container in the compose file.

```bash
docker build -f .docker/Dockerfile -t samhwang/php:latest \
    --build-arg ENVIRONMENT=[development,staging,production] \
    --build-arg XDEBUG_ENABLE=[true,false] \
    .
```

## Composing the network

To run the image and connect it with the rest of the network
(including Composer, MySQL and Adminer), you will need to
create your own .env file. A sample is provided as .env.sample.
And then you can run these commands:

```bash
# Add -d to running in background
# Add --build to rebuild the image
docker-compose up
docker-compose down
```
