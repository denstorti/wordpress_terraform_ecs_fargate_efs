DOCKER_COMPOSE_RUN_TERRAFORM = docker-compose run --rm terraform
DOCKER_COMPOSE_RUN_AWS = docker-compose run --rm aws

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

ENVIRONMENT?=dev

.PHONY: .env

.env:
	-rm .env
	cp .env.${ENVIRONMENT} .env

prepare:
	docker-compose build

terraform_backend: 
	-$(DOCKER_COMPOSE_RUN_AWS) s3 mb s3://${TERRAFORM_STATE_BUCKET}

network: .env network_init network_deploy

network_init: .env 
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _network_init

_network_init:
	sh scripts/terraform_init.sh

_network_deploy:
	sh scripts/network_deploy.sh

network_deploy:
		$(DOCKER_COMPOSE_RUN_TERRAFORM) make _network_deploy

shellTerraform:
	docker-compose run --rm terraform

shellAWS:
	docker-compose run --rm --entrypoint bash aws

clean:
	git clean -fxd
	rm -rf output/