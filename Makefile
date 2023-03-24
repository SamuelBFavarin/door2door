DBT_IMAGE_NAME ?= door2door_core
INGESTION_IMAGE_NAME ?= door2door_core
TAG ?= dev

run-dbt:    ./transformation/Dockerfile
	cp credentials/sa-gcp-key.json transformation/temp-sa-gcp-key.json
	mv transformation/profiles.yml transformation/profiles.prod.yml
	mv transformation/profiles.local.yml transformation/profiles.yml
	docker build -t ${DBT_IMAGE_NAME}:${TAG} -f ./transformation/Dockerfile .
	touch .container_bash_history
	docker-compose -f ./transformation/docker-compose.yml --profile dbt run -p 9444:8080 --rm --name ${DBT_IMAGE_NAME} ${DBT_IMAGE_NAME} bash --rcfile .bashrc -i
	rm ./transformation/temp-sa-gcp-key.json
	mv transformation/profiles.yml transformation/profiles.local.yml
	mv transformation/profiles.prod.yml transformation/profiles.yml

run-ingestion:	./ingestion/Dockerfile.local
	cp credentials/sa-gcp-key.json ingestion/temp-sa-gcp-key.json
	docker build -t ${INGESTION_IMAGE_NAME}:${TAG} -f ./ingestion/Dockerfile.local .
	docker run -t ${INGESTION_IMAGE_NAME}:${TAG}
	rm ./ingestion/temp-sa-gcp-key.json
