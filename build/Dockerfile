FROM nginx:latest

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
	python3.7 \
	python3-mako \
	python3-yaml \
	&& rm -rf /var/lib/apt/lists/*

COPY ./templates /config_gen/templates

COPY ./generate_config.py /config_gen/generate_config.py
COPY ./99-generate_config.sh /docker-entrypoint.d/99-generate_config.sh
RUN chmod +x /docker-entrypoint.d/99-generate_config.sh

# Empty config file by default; expects real one to be mounted in at runtime
RUN mkdir /config && touch /config/config.yml
