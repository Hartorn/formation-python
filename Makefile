SVC_NB="dev_notebook"
SVC_DEV="dev_service"

default: help;

##### Docker specific #####

deps: ## Install virtual env
	make docker svc=${SVC_DEV} cmd="poetry install --sync"
.PHONY: deps

docker: ## Run command in docker (use cmd="python3 hawk/main.py --help" for inline, or nothing for interactive)
	docker compose run ${opts} --rm ${svc} ${cmd}
.PHONY: docker

##### Poetry specific #####

build: _env ## Build a service from docker-compose (or all if no svc="example" is given)
	docker compose build --pull
.PHONY: build

shell: ## Open virtualenv in docker (for poetry)
	make docker svc=${SVC_DEV} cmd="poetry shell"
.PHONY: shell

notebook: build ## Start notebook server
	docker compose up -d ${SVC_NB}
.PHONY: notebook

stop_notebook: ## Stop the notebook server
	${DCK} rm -f -s ${SVC_NB}
.PHONY: stop_notebook

##### Utilities #####

clean: ## Clean all venv, python byte code, and so on.
	ls | grep env_ | xargs rm -rf
	find . -type d -name __pycache__ | xargs rm -rf
	find . -type d | grep ".egg-info" | xargs rm -rf
	find . -type d -name pip-wheel-metadata | xargs rm -rf
	rm -rf lightning_logs outputs dist build MNISTExample .pytest_cache logs
.PHONY: clean

clear_docker: ## Clean docker (containers, volumes, networks but not images and cache)
	docker rm $$(docker ps -a -q) -f 2>/dev/null || echo "Always OK"
	docker system prune -f
	docker volume prune -f
.PHONY: clear_docker

clear_all_docker: clear_docker ## Clean docker fully (including images and cache)
	docker rmi $$(docker images -a -q) -f 2>/dev/null || echo "Always OK"
	docker system prune -f
.PHONY: clear_all_docker

help: ## Display commands help
	@grep -E '^[a-zA-Z][a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

##### Internals #####
_env: ## Build .env with needed info for docker-compose
	echo "USER_UID=$$(id -u)" > .env
	echo "USER_GID=$$(id -g)" >> .env
	echo "USERNAME=$$(id -un)" >> .env
.PHONY: _env
