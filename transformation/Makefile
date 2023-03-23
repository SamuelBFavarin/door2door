DBT_IMAGE_NAME ?= door2door_core
TAG ?= dev

dbt:    ./Dockerfile
	docker build -t ${DBT_IMAGE_NAME}:${TAG} -f ./Dockerfile .
	touch .container_bash_history
	docker-compose --profile dbt run -p 9444:8080 --rm --name ${DBT_IMAGE_NAME} ${DBT_IMAGE_NAME} bash --rcfile .bashrc -i