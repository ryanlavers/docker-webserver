#!/bin/sh

env python3 /config_gen/generate_config.py /config_gen/templates /config/config.yml /etc/nginx/nginx.conf
cat /etc/nginx/nginx.conf
