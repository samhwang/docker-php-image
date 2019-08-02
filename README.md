# Docker PHP Environment

My general use Docker PHP image for development.

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
