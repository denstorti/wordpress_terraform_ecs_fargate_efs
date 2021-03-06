DOCKER_COMPOSE_RUN_TERRAFORM = docker-compose run --rm terraform
DOCKER_COMPOSE_RUN_AWS = docker-compose run --rm aws

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

ENVIRONMENT?=dev
PROJECT_NAME ?= project01
APPLICATION ?= wordpress
TERRAFORM_STATE_BUCKET ?= terraform-state-denis

DB_NAME ?= ${APPLICATION}

COMPOSE_PROJECT_NAME = ${PROJECT_NAME}
TF_VAR_project_name=${PROJECT_NAME}
TF_VAR_environment=${ENVIRONMENT}
TF_VAR_application=${APPLICATION}
TF_VAR_bucket_tf_state=${TERRAFORM_STATE_BUCKET}

TF_VAR_db_name=${DB_NAME}
TF_VAR_db_user=${DB_USER}

AWS_IMAGE = aws_3m
TERRAFORM_IMAGE = terraform_3m
WORDPRESS_IMAGE = wordpress
GIT_SHA = git rev-parse --short HEAD

.PHONY: .env
.EXPORT_ALL_VARIABLES: 
.DEFAULT_GOAL := all

.env:
	-rm .env
	cp .env.${ENVIRONMENT} .env


all: prepare deploy_network deploy_data

prepare: .env terraform_backend terraform_init

build:
	docker build -f Dockerfile.aws_3m -t ${AWS_IMAGE}:$(shell ${GIT_SHA}) .
	docker build -f Dockerfile.terraform -t ${TERRAFORM_IMAGE}:$(shell ${GIT_SHA}) .
	docker build -f Dockerfile.wordpress -t ${WORDPRESS_IMAGE}:$(shell ${GIT_SHA}) .

push:   # requires Git, AWS and Docker
	bash scripts/push.sh

terraform_backend: .env
	$(DOCKER_COMPOSE_RUN_AWS) make _terraform_backend

deploy: deploy_network deploy_data

deploy_network: terraform_switch_network validate_network
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _network_deploy

deploy_data: terraform_switch_data validate_data
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _data_deploy

undeploy: undeploy_data undeploy_network

undeploy_network: terraform_switch_network validate_network 
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _undeploy_network

undeploy_data: terraform_switch_data validate_data 
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _undeploy_data

validate_network:
	$(DOCKER_COMPOSE_RUN_TERRAFORM) terraform validate terraform/

validate_data:
	$(DOCKER_COMPOSE_RUN_TERRAFORM) terraform validate terraform_data/

terraform_init: .env 
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _terraform_init
terraform_switch_data:
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _terraform_switch_data
terraform_switch_network:
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _terraform_switch_network

terraform_refresh:
		$(DOCKER_COMPOSE_RUN_TERRAFORM) make _terraform_refresh

shellTerraform:
	docker-compose run --rm terraform
shellAWS:
	docker-compose run --rm --entrypoint bash aws
shellWP:
	docker-compose run --rm --entrypoint bash wordpress


clean:
	git clean -fxd
	rm -rf output/

_terraform_refresh:
		sh terraform refresh terraform/

_terraform_init:
	sh scripts/terraform_init.sh

_terraform_switch_data:
	sh scripts/terraform_switch_data.sh
_terraform_switch_network:
	sh scripts/terraform_switch_network.sh

_network_deploy:
	sh scripts/network_deploy.sh

_data_deploy:
	sh scripts/data_deploy.sh

_undeploy_network:
	sh scripts/network_undeploy.sh

_undeploy_data:
	sh scripts/data_undeploy.sh

_terraform_backend: 
	-aws s3 mb s3://${TERRAFORM_STATE_BUCKET}