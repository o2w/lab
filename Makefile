AEM=acs

#https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile
MAKE_ROOT:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

PREPARED_DOCKER_COMPOSE_YML=.prepared.docker-compose.yml

PROJECT=eval.${AEM}

test: ## print test message
	@echo 20180508

aem: ## Build base image of AEM
	@cd ./aem${AEM}; ls aem-sdk-2*.zip | xargs -I{} unzip -n {}
	@cd ./aem${AEM}; ls cq-quickstart*.zip | xargs -I{} unzip -n {}
	@javadeb=`cd ./aem${AEM}; ls | sort | grep -E '(jdk-11.*\.deb|jdk-8.*\.tar\.gz)' | tail -n1` && \
		acssdk=`cd ./aemacs; ls | sort | grep 'aem-sdk-quickstart' | tail -n1` && \
		echo $$javadeb && \
		echo $$acssdk && \
		docker build -t aem${AEM} ./aem${AEM} --build-arg JAVADEB="$${javadeb}" --build-arg ACSSDK="$${acssdk}"

prepare-docker-compose-yml: ##Create tailord docker-compose.yml for given condition
	@cp -f docker-compose.yml ${PREPARED_DOCKER_COMPOSE_YML}
	@sed -i.back -e 's/{{AEM_VERSION}}/${AEM}/' ${PREPARED_DOCKER_COMPOSE_YML}
	@sed -i.back -e 's|{{MAKE_ROOT}}|${MAKE_ROOT}|' ${PREPARED_DOCKER_COMPOSE_YML}
	@cat .prepared.docker-compose.yml >&2

build: ##execute docker compose with configuration
	@make -s prepare-docker-compose-yml
	@docker compose -f ${PREPARED_DOCKER_COMPOSE_YML} build --build-arg AEM=aem${AEM}

init: ## Initiate a set of instances/containers
	@make -s aem
	@make -s build
	@./install_packages.sh author custom/${PROJECT} &
	@./install_packages.sh publish custom/${PROJECT} &
	@echo "${AEM}" | grep '6.4' || ./install_wknd.sh &
	@mkdir -p custom/${PROJECT} && \
		cd custom/${PROJECT} && \
		pwd && \
		cp -av ${MAKE_ROOT}/${PREPARED_DOCKER_COMPOSE_YML} ./docker-compose.yml && \
		dir=author; mkdir -p $$dir && cp -a ${MAKE_ROOT}/$$dir/Dockerfile ./$$dir && \
		dir=publish; mkdir -p $$dir && cp -a ${MAKE_ROOT}/$$dir/Dockerfile ./$$dir && \
		dir=dispatcher; mkdir -p $$dir && cp -a ${MAKE_ROOT}/$$dir/Dockerfile ./$$dir && \
		docker compose up

#Replecation agent
#https://experienceleague.adobe.com/en/docs/experience-manager-65/content/implementing/deploying/configuring/replication#replication-out-of-the-box

#Access below url to browse what's up
#http://localhost:4502/libs/granite/operations/content/systemoverview.html

#https://forums.docker.com/t/how-to-delete-cache/5753/14
#https://stackoverflow.com/questions/45357771/stop-and-remove-all-docker-containers
rm: ## Remove all images available. Beaware not only the one made from this script
	-@docker stop $(shell docker ps -a -q)
	-@docker rm $(shell docker ps -a -q)
	-@docker rmi $(shell docker images -a --filter=dangling=true -q)
	-@docker rm $(shell docker ps --filter=status=exited --filter=status=created -q)
	-@docker system prune -a
	-@docker builder prune

login:
	@docker exec -it $(shell docker ps | grep author | awk '{print $$1}') /bin/bash

up: # Create a copy of containers from existing ones and launch. Originals would completely kept behind and temporal containers will be gone in the end
	@make -s prepare-docker-compose-yml
	-@docker ps -a | grep  -E 'tmp.*${PROJECT}' | awk '{print $$1}' | xargs docker rm
	@./disposable.sh "${PROJECT}"

local-author-mac:
	@cd `mktemp -d` && \
		pwd && \
		echo ${MAKE_ROOT} && \
		java -version && \
		cp ${MAKE_ROOT}/aemacs/aem-sdk-quickstart.jar ./cq-quickstart.jar && \
		java -jar cq-quickstart.jar -unpack && \
		cp -r ${MAKE_ROOT}/aemacs/install ./crx-quickstart/ && \
		mv ./cq-quickstart.jar ./aem-author-p4502.jar && \
		java -jar ./aem-author-p4502.jar -forkargs -- -Xmx2024m

.PHONY: help

help: ## print about the targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

