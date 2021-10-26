#!/bin/bash

docker run --rm -it \
  -v $PWD/log/:/var/log/letsencrypt/ \
  -v $PWD/etc/:/etc/letsencrypt/ \
  certbot/certbot certonly --webroot -w /etc/letsencrypt/webroot
