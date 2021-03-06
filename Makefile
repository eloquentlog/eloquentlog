application = eloquentlog
network = $(application)-net

repository_host = gitlab.com
repository_user = $(application)

repositories = \
	$(application)-console-api \
	$(application)-cli \
	$(application)-data \
	$(application)-web-

srv ?= $(shell pwd)/srv

rc:
ifeq ($(shell ps -ef | grep "[d]ockerd" | awk {'print $2'}),)
	@echo "docker daemon does not exist" && exit 1
endif

checkout:
	@if [ ! -d "$(srv)" ]; then \
		mkdir $(srv); \
	fi
	@for repository in $(repositories); do \
		if [ ! -d "$(srv)/$$repository" ]; then \
			git clone git@$(repository_host):$(repository_user)/$$repository.git \
				$(srv)/$$repository && cd $(srv)/$$repository; \
			git remote rename origin gitlab; \
		else \
			cd $(srv)/$$repository; \
			git pull gitlab master; \
		fi \
	done
.PHONY: checkout

network: rc
	@if docker network inspect $(network) >/dev/null 2>&1; then \
		echo "network named as $(network) already exists"; \
	else \
		docker network create \
			-o "com.docker.network.bridge.name"="$(network)" $(network); \
	fi
.PHONY: network

init: rc network checkout
	@docker-compose -f docker-compose.yml -p $(application) up
.PHONY: init

up: rc network
ifeq ($(shell [ "true" = "$${FETCH}" ] && echo $$?), 0)
	make checkout
endif
	@docker-compose -f docker-compose.yml -p $(application) up -d
.PHONY: up

down: rc
	@docker-compose -f docker-compose.yml -p $(application) down
.PHONY: down

clean: rc
	@docker-compose -f docker-compose.yml -p $(application) down \
		--rmi local --volumes
	@if docker images | \
		grep localhost:5000/$(application)/$(application)-data; then \
		docker rmi localhost:5000/$(application)/$(application)-data:latest; \
	fi
	@if docker images | grep $(application)-data; then \
		docker rmi $(application)/$(application)-data:latest; \
	fi
.PHONY: clean

start: up
.PHONY: start

stop: rc
	@docker-compose -f docker-compose.yml -p $(application) stop
.PHONY: stop

restart: rc
	@docker-compose -f docker-compose.yml -p $(application) restart
.PHONY: restart

# swarm -- {{{
node\:join:
	@docker container exec -it $(application)-manager docker swarm init \
		>/dev/null
	@docker container exec -it $(application)-manager docker network create \
	--driver=overlay --attachable $(application) >/dev/null
	@token="$$( \
	  docker container exec -it $(application)-manager \
	  docker swarm join-token worker | grep token | awk '{print $$5}' \
	)" && \
	for i in `seq 1 3`; do \
		docker container exec -it "$(application)-worker-0$${i}" \
		docker swarm join --token "$${token}" $(application)-manager:2377; \
	done
.PHONY: node\:join

join: node\:join
.PHONY: join

node\:leave:
	@for i in `seq 1 3`; do \
		docker container exec -it "$(application)-worker-0$${i}" \
			docker swarm leave; \
	done
	@docker container exec -it $(application)-manager docker swarm leave --force
.PHONY: node\:leave

leave: node\:leave
.PHONY: leave

node\:info:
	@echo "# $(shell date --rfc-3339=ns)"
	@echo "# network: ${application}"
	@echo ""
	@echo "[postgresql:master]"
	@echo "docker container exec -it $(shell docker container exec -it \
		$(application)-manager docker service ps ${application}-postgresql_master \
		--no-trunc \
		--filter 'desired-state=running' \
		--format '{{.Node}} docker exec -it {{.Name}}.{{.ID}}')"
	@echo ""
	@echo "[postgresql:slave]"
	@echo "$$(docker container exec -it $(application)-manager \
		docker service ps $(application)-postgresql_slave \
		--no-trunc \
		--filter 'desired-state=running' \
		--format '{{.Node}} docker exec -it {{.Name}}.{{.ID}}')" | \
		while read line; do \
			echo "docker container exec -it $${line}"; \
		done
	@echo ""
	@echo "[postgresql:data]"
	@echo "$$(docker container exec -it $(application)-manager \
		docker service ps $(application)-postgresql_data \
		--no-trunc \
		--filter 'desired-state=running' \
		--format '{{.Node}} docker exec -it {{.Name}}.{{.ID}}')" | \
		while read -r line; do \
			echo "docker container exec -it $${line}"; \
		done
	@echo ""
	@echo "[redis:master]"
	@echo "docker container exec -it $(shell docker container exec -it \
		$(application)-manager docker service ps ${application}-redis_master \
		--no-trunc \
		--filter 'desired-state=running' \
		--format '{{.Node}} docker exec -it {{.Name}}.{{.ID}}')"
	@echo ""
	@echo "[redis:slave]"
	@echo "docker container exec -it $(shell docker container exec -it \
		$(application)-manager docker service ps ${application}-redis_slave \
		--no-trunc \
		--filter 'desired-state=running' \
		--format '{{.Node}} docker exec -it {{.Name}}.{{.ID}}')"
	@echo ""
.PHONY: node\:info

info: node\:info
.PHONY: info

deploy\:data:
	@echo "* building $(application)-data a container..."
	# move sql files (for migrations)
	@rm -fr srv/$(application)-data/schema/*
	@cp -R srv/$(application)-console-api/migration/* \
		srv/$(application)-data/schema/
	# build external image (data)
	@docker image build -f srv/$(application)-data/Dockerfile \
		-t $(application)/$(application)-data:latest srv/$(application)-data
	@docker image tag $(application)/$(application)-data:latest \
		localhost:5000/$(application)/$(application)-data:latest
	@docker image push localhost:5000/$(application)/$(application)-data:latest
.PHONY: deploy\:data

deploy\:data\:export:
	@echo "TODO"
.PHONY: deploy\:data\:export

deploy\:data\:import:
	@echo "TODO"
.PHONY: deploy\:data\:import

deploy\:data\:update:
	@docker container exec -it $(application)-manager docker service update \
		$(application)-postgresql_data
.PHONY: deploy\:data\:update

deploy\:postgresql:
	@echo "* deploying $(application)-postgresql service containers..."
	@echo
	@docker container exec -it $(application)-manager docker stack deploy \
		-c ./stack/$(application)-postgresql.yml $(application)-postgresql
.PHONY: deploy\:postgresql

deploy\:redis:
	@echo "* deploying $(application)-redis service containers..."
	@echo
	@docker container exec -it $(application)-manager docker stack deploy \
		-c ./stack/$(application)-redis.yml $(application)-redis
.PHONY: deploy\:redis

deploy\:visualizer:
	@echo "* deploying $(application)-visualizer service containers..."
	@echo
	@docker container exec -it $(application)-manager docker stack deploy \
		-c ./stack/$(application)-visualizer.yml $(application)-visualizer
.PHONY: deploy\:visualizer
# }}}
