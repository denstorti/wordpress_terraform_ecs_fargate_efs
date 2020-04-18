DOCKER_RUN_TERRAFORM = docker-compose run --rm terraform


network_init:
	$(DOCKER_RUN_TERRAFORM) init terraform/

network_deploy: network_init
	$(DOCKER_RUN_TERRAFORM) plan terraform/
	$(DOCKER_RUN_TERRAFORM) apply terraform/

	