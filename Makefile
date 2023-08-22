SHELL=/bin/bash
RED=\033[0;31m
GREEN=\033[0;32m
BG_GREY=\033[48;5;237m
NC=\033[0m # No Color

include project.env
export $(shell sed 's/=.*//' project.env)


.PHONY: help

help:
	@echo OleksiiHonchar.com automation commands:
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check-project-env-vars:
	@bash ./devops/local/scripts/check-project-env-vars.sh


up: check-project-env-vars ## docker up
	@docker compose -f ./docker-compose.yaml up --remove-orphans -d

down: check-project-env-vars ## docker down
	@docker compose -f ./docker-compose.yaml down

logs: ## docker logs
	@docker compose logs --follow

restart: dockerComposeFile = ./docker-compose.yaml
restart: ## restart all
	@docker compose -f $(dockerComposeFile) down
	@docker compose -f $(dockerComposeFile) up --remove-orphans -d
	@docker compose  -f $(dockerComposeFile) logs --follow

nginx-exec-bush: ## get shell for nginx container
	@docker exec -it nginx bash

