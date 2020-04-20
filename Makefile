DOCKER_COMPOSE_RUN_TERRAFORM = docker-compose run --rm terraform
DOCKER_COMPOSE_RUN_AWS = docker-compose run --rm aws

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

ENVIRONMENT?=dev
PROJECT_NAME ?= project01
APPLICATION ?= wordpress
TERRAFORM_STATE_BUCKET ?= terraform-state-denis

#To do: remove this and fetch from SSM Parameter store
ECR_REPO ?= 281387974444.dkr.ecr.ap-southeast-2.amazonaws.com

DB_NAME ?= ${APPLICATION}

COMPOSE_PROJECT_NAME = ${PROJECT_NAME}
TF_VAR_project_name=${PROJECT_NAME}
TF_VAR_environment=${ENVIRONMENT}
TF_VAR_application=${APPLICATION}
TF_VAR_bucket_tf_state=${TERRAFORM_STATE_BUCKET}

TF_VAR_db_name=${DB_NAME}
TF_VAR_db_user=${DB_USER}
# TF_VAR_db_password=${DB_PASSWORD}

AWS_IMAGE = aws_3m
TERRAFORM_IMAGE = terraform_3m

.PHONY: .env
.EXPORT_ALL_VARIABLES: 
.DEFAULT_GOAL := all

.env:
	-rm .env
	cp .env.${ENVIRONMENT} .env


all: prepare deploy_network deploy_data

prepare:  
	$(MAKE) .env
	$(MAKE) terraform_init
	$(MAKE) terraform_backend

build:
	GIT_SHA=$(shell git rev-parse --short HEAD)
	docker build -f Dockerfile.aws_3m -t ${AWS_IMAGE}:${GIT_SHA} .
	docker build -f Dockerfile.terraform -t ${TERRAFORM_IMAGE}:${GIT_SHA} .

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

push:
	bash scripts/push.sh

terraform_init: .env 
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _terraform_init
terraform_switch_data: .env 
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _terraform_switch_data
terraform_switch_network:
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _terraform_switch_network

terraform_refresh:
		$(DOCKER_COMPOSE_RUN_TERRAFORM) make _terraform_refresh
_terraform_refresh:
		sh terraform refresh terraform/

shellTerraform:
	docker-compose run --rm terraform
shellAWS:
	docker-compose run --rm --entrypoint bash aws

clean:
	git clean -fxd
	rm -rf output/

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