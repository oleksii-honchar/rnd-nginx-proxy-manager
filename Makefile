SHELL=/bin/bash
RED=\033[0;31m
GREEN=\033[0;32m
BG_GREY=\033[48;5;237m
YELLOW=\033[38;5;202m
NC=\033[0m # No Color
BOLD_ON=\033[1m
BOLD_OFF=\033[21m
CLEAR=\033[2J

include project.env
export $(shell sed 's/=.*//' project.env)

.PHONY: help

help:
	@echo OleksiiHonchar.com automation commands:
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.ONESHELL:
check-project-env-vars:
	@bash ./devops/local/scripts/check-project-env-vars.sh

logs: ## docker logs
	@docker compose logs --follow

log: ## docker log for svc=<docker service name>
	@docker compose logs --follow ${svc}

up: generate-config check-project-env-vars ## docker up, or svc=<svc-name>
	@docker compose up --build --remove-orphans -d ${svc}

down: check-project-env-vars ## docker down, or svc=<svc-name>
	@docker compose down ${svc}

.ONESHELL:
restart: generate-config check-project-env-vars ## restart all
	@docker compose down
	@docker compose up --build --remove-orphans -d
	@docker compose logs --follow

.ONESHELL:
restart-one: generate-config check-project-env-vars ## restart all or svc=<svc-name>
	@docker compose stop ${svc}
	@docker compose up --build --remove-orphans -d ${svc}
	@docker compose logs --follow

exec-bash: ## get shell for svc=<svc-name> container
	@docker exec -it ${svc} bash

exec-sh: ## get shell for svc=<svc-name> container
	@docker exec -it ${svc} sh

build-squid:
	@docker build --load -f ./squid/Dockerfile -t tuiteraz/squid --platform linux/arm64 .

generate-config:
	@bash ./generate-config.bash
