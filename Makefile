application = eloquentlog
network = $(application)-net

repository_host = gitlab.com
repository_user = $(application)

repositories = \
	$(application)-backend-api \
	$(application)-cli \
	$(application)-data \
	$(application)-web-frontend

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
.PHONY: up

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

data:
	@echo "* building $(application)-data a container..."
	# external (data)
	@docker image build -f srv/$(application)-data/Dockerfile \
	  -t $(application)/$(application)-data:latest srv/$(application)-data
	@docker image tag $(application)/$(application)-data:latest \
	  localhost:5000/$(application)/$(application)-data:latest
	@docker image push localhost:5000/$(application)/$(application)-data:latest
.PHONY: data

deploy\:postgresql:
	@echo "* deploying $(application)-postgresql service containers..."
	@echo
	@docker container exec -it $(application)-manager docker stack deploy \
	  -c ./stack/$(application)-postgresql.yml $(application)-postgresql
.PHONY: deploy\:postgresql

deploy\:visualizer:
	@echo "* deploying $(application)-visualizer service containers..."
	@echo
	@docker container exec -it $(application)-manager docker stack deploy \
	  -c ./stack/$(application)-visualizer.yml $(application)-visualizer
.PHONY: deploy\:visualizer
# }}}
