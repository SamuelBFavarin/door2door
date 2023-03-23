#!/bin/sh

# Credits to michaeloliverx
# https://github.com/michaeloliverx/python-poetry-docker-example/blob/master/docker/docker-entrypoint.sh

set -e

# Need to sleep because GCP might do something with .env file causing conflict operation
[ -d "/opt/secrets" ] && [ ! -L "/opt/secrets" ] && sleep 15 && ln -s /opt/secrets/.env /app/.env

# activate our virtual environment here
. /opt/pysetup/.venv/bin/activate

# You can put other setup logic here

# Evaluating passed command:
exec "$@"