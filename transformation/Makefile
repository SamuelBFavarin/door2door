DBT_IMAGE_NAME ?= door2door_core
TAG ?= dev

## Enter the dbt docker container, also builds the container if it has not been created yet
dbt:    ./Dockerfile
	export DOCKER_BUILDKIT=0
	export COMPOSE_DOCKER_CLI_BUILD=0
	$$(docker image inspect ${DBT_IMAGE_NAME}:${TAG} > /dev/null 2>&1) || docker build -t ${DBT_IMAGE_NAME}:${TAG} -f ./Dockerfile .
	touch .container_bash_history
	docker-compose --profile dbt run -p 9444:8080 --rm --name ${DBT_IMAGE_NAME} ${DBT_IMAGE_NAME} bash --rcfile .bashrc -i

## Enter the dbt docker container, also builds the container if it has not been created yet
dbt-full:    ./Dockerfile
	export DOCKER_BUILDKIT=0
	export COMPOSE_DOCKER_CLI_BUILD=0
	docker build -t ${DBT_IMAGE_NAME}:${TAG} -f ./Dockerfile .
	touch .container_bash_history
	docker-compose --profile dbt run -p 9444:8080 --rm --name ${DBT_IMAGE_NAME} ${DBT_IMAGE_NAME} bash --rcfile .bashrc -i