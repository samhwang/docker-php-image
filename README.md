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

## TODO

- Add support to change environment between dev and staging/production
- Finish with guide to run this image, and also docker-composing it.
- Install composer and prestissimo
