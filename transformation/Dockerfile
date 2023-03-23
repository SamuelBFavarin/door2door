FROM python:3.10.9-slim

LABEL Pipeline door2door

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

RUN apt-get update \
    && apt-get install --no-install-recommends -y curl gcc git jq\
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV POETRY_VERSION=1.3.2
RUN curl -sSL https://install.python-poetry.org | python3 -

WORKDIR $PYSETUP_PATH
COPY ./pyproject.toml ./
RUN poetry install --extras dbt

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT /docker-entrypoint.sh $0 $@

WORKDIR /app

ENV ENV_NAME=prod
ENV DBT_PROJECT=door2door-381302
ENV DBT_DEFAULT_DATASET=default
ENV DBT_PROFILES_DIR=./

COPY . /app/


#RUN chmod +x ./ci/run_ci.sh 
#ENTRYPOINT ./ci/run_ci.sh