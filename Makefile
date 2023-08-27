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

logs: dockerComposeFile = ./docker-compose.yaml
logs: ## docker logs
	@docker compose -f $(dockerComposeFile) logs --follow

up: dockerComposeFile = ./docker-compose.yaml
up: check-project-env-vars ## docker up, or or svc=<svc-name>
	@docker compose -f $(dockerComposeFile) up --build --remove-orphans -d ${svc}

down: dockerComposeFile = ./docker-compose.yaml
down: check-project-env-vars ## docker down, or svc=<svc-name>
	@docker compose -f $(dockerComposeFile) down ${svc}

restart: dockerComposeFile = ./docker-compose.yaml
restart: ## restart all
	@docker compose -f $(dockerComposeFile) down
	@docker compose -f $(dockerComposeFile) up --build --remove-orphans -d
	@docker compose  -f $(dockerComposeFile) logs --follow

restart-one: dockerComposeFile = ./docker-compose.yaml
restart-one: ## restart all or svc=<svc-name>
	@docker compose -f $(dockerComposeFile) stop ${svc}
	@docker compose -f $(dockerComposeFile) up --build --remove-orphans -d ${svc}
	@docker compose  -f $(dockerComposeFile) logs --follow

nginx-exec-bush: ## get shell for nginx container
	@docker exec -it nginx bash

# DNSmasq

build-dnsmasq:
	@docker build --load -f ./dnsmasq/Dockerfile -t tuiteraz/dnsmasq:2.85-r2 .
