#!bin/bash

# Build the base images
docker build -f Dockerfile-apache-debian -t ${DOCKER_USERNAME}/php:7.3 .
docker build -f Dockerfile-nginx-debian -t ${DOCKER_USERNAME}/php:7.3-nginx .
docker build -f Dockerfile-apache-alpine -t ${DOCKER_USERNAME}/php:7.3-apache-alpine .
docker build -f Dockerfile-nginx-alpine -t ${DOCKER_USERNAME}/php:7.3-nginx-alpine .

# Tag apache-debian as the main image
docker tag ${DOCKER_USERNAME}/php:7.3 ${DOCKER_USERNAME}/php:7.3-apache
docker tag ${DOCKER_USERNAME}/php:7.3 ${DOCKER_USERNAME}/php:latest

# Push to Docker Cloud
docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD} docker.io
docker push ${DOCKER_USERNAME}/php:latest
docker push ${DOCKER_USERNAME}/php:7.3
docker push ${DOCKER_USERNAME}/php:7.3-apache
docker push ${DOCKER_USERNAME}/php:7.3-nginx
docker push ${DOCKER_USERNAME}/php:7.3-apache-alpine
docker push ${DOCKER_USERNAME}/php:7.3-nginx-alpine