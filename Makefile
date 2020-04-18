DOCKER_COMPOSE_RUN_TERRAFORM = docker-compose run --rm terraform
DOCKER_COMPOSE_RUN_AWS = docker-compose run --rm aws

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

export ENVIRONMENT?=dev
export PROJECT_NAME ?= project01
export APPLCATION ?= wordpress
export TERRAFORM_STATE_BUCKET ?= terraform-state-denis
ECR_REPO ?= 281387974444.dkr.ecr.ap-southeast-2.amazonaws.com

export COMPOSE_PROJECT_NAME = ${PROJECT_NAME}
export TF_VAR_project_name=${PROJECT_NAME}
export TF_VAR_environment=${ENVIRONMENT}
export TF_VAR_application=${APPLCATION}
export TF_VAR_bucket_tf_state=${TERRAFORM_STATE_BUCKET}

GIT_SHA=$(shell git rev-parse --short HEAD)
AWS_IMAGE = aws_3m
TERRAFORM_IMAGE = terraform_3m
.PHONY: .env

.env:
	-rm .env
	cp .env.${ENVIRONMENT} .env

build:  
	$(MAKE) terraform_init
	$(MAKE) terraform_backend
	docker build -f Dockerfile.aws_3m -t ${AWS_IMAGE}:{GIT_SHA} .
	docker build -f Dockerfile.terraform -t ${TERRAFORM_IMAGE}:${GIT_SHA} .

terraform_backend: .env
	-$(DOCKER_COMPOSE_RUN_AWS) make _terraform_backend

deploy: validate network

undeploy: validate network_undeploy

validate:
	$(DOCKER_COMPOSE_RUN_TERRAFORM) terraform validate terraform/

network: .env terraform_init network_deploy

push:
	# aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${ECR_REPO}/${AWS_IMAGE}
	# docker tag ${AWS_IMAGE}:${GIT_SHA} ${ECR_REPO}/${AWS_IMAGE}:${GIT_SHA}
	# docker push ${ECR_REPO}/${AWS_IMAGE}:${GIT_SHA}
	
	aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${ECR_REPO}/${TERRAFORM_IMAGE}
	docker tag ${TERRAFORM_IMAGE}:${GIT_SHA} ${ECR_REPO}/${TERRAFORM_IMAGE}:${GIT_SHA}
	docker push ${ECR_REPO}/${TERRAFORM_IMAGE}:${GIT_SHA}

terraform_init: .env 
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _terraform_init
network_deploy:
		$(DOCKER_COMPOSE_RUN_TERRAFORM) make _network_deploy
network_undeploy:
	$(DOCKER_COMPOSE_RUN_TERRAFORM) make _network_undeploy

shellTerraform:
	docker-compose run --rm terraform
shellAWS:
	docker-compose run --rm --entrypoint bash aws

clean:
	git clean -fxd
	rm -rf output/

_terraform_init:
	sh scripts/terraform_init.sh

_network_deploy:
	sh scripts/network_deploy.sh

_network_undeploy:
	sh scripts/network_undeploy.sh

_terraform_backend: 
	aws s3 mb s3://${TERRAFORM_STATE_BUCKET}