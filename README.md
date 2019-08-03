# Docker PHP Environment

My general use Docker PHP setup for development.

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

You will need to generate self-signed SSL keys first, and
put them in .docker/ssl, and then use `docker run` to run
the image.

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout .docker/server.key -out .docker/server.crt

docker run -d --rm -p 80:80 -p 443:443 --name=testing samhwang/php
curl http://localhost
curl https://localhost/
docker stop testing
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

## TODO

- Add support to change environment between dev and staging/production.
- Install prestissimo via composer.
