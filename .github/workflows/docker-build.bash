#!bin/bash

# Build the base images
docker build -f Dockerfile-apache-alpine -t samhwang/php:7.3 .
docker build -f Dockerfile-apache-debian -t samhwang/php:7.3-nginx .
docker build -f Dockerfile-nginx-alpine -t samhwang/php:7.3-apache-alpine .
docker build -f Dockerfile-nginx-debian -t samhwang/php:7.3-nginx-alpine .

# Tag apache-debian as the main image
docker tag samhwang/php:7.3 samhwang/php:7.3-apache
docker tag samhwang/php:7.3 samhwang/php:latest

# Push to Docker Cloud
docker push samhwang/php:latest
docker push samhwang/php:7.3
docker push samhwang/php:7.3-apache
docker push samhwang/php:7.3-nginx
docker push samhwang/php:7.3-apache-alpine
docker push samhwang/php:7.3-nginx-alpine