#!/bin/bash
echo "Clean docker containers and images"
docker container stop wordpress-with-plugins-wordpress-1
docker container rm wordpress-with-plugins-wordpress-1
docker image rm  e-labo/wordpress:wp-8.2-fpm
