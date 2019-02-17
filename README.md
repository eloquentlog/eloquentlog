# Eloquentlog

## Note

### Setup

#### Nodes & Networks

```zsh
% make up

% docker container exec -it manager docker swarm init
% docker container exec -it worker-01 docker swarm join \
  --token <token> manager:2377
% docker container exec -it worker-02 docker swarm join \
  --token <token> manager:2377
% docker container exec -it worker-03 docker swarm join \
  --token <token> manager:2377
% docker container exec -it manager docker network create \
  --driver=overlay --attachable eloquentlog
```

#### Containers

##### Visualizer

This is optional.

```zsh
# visualizer
% docker container exec -it manager docker stack deploy \
  -c ./stack/visualizer.yml visualizer
```

##### PostgreSQL

```zsh
# postgres
% docker image build -f srv/eloquentlog-data/Dockerfile \
  -t eloquentlog/eloquentlog-data:latest srv/eloquentlog-data
% docker image tag eloquentlog/eloquentlog-data:latest \
  localhost:5000/eloquentlog/eloquentlog-data:latest
% docker image push localhost:5000/eloquentlog/eloquentlog-data:latest
```

```zsh
% docker container exec -it manager docker stack deploy \
  -c ./stack/eloquentlog-data.yml eloquentlog-data
```

###### Display containers

```zsh
# display containers `<node> <name>.<id>` for master
% docker container exec -it manager docker service ps \
  eloquentlog-data --no-trunc --filter "desired-state=running" \
  --format "{{.Node}} {{.Name}}.{{.ID}}"

# display containers `<node> <name>.<id>` for slave
% docker container exec -it manager docker service ps \
  eloquentlog-data --no-trunc --filter "desired-state=running" \
  --format "{{.Node}} {{.Name}}.{{.ID}}"
```

###### Create Schema

```zsh
# master
% docker container exec -it  docker exec -it <node> \
  docker container exec -it <node> docker exec -it <name>.<id> psql -U USER DATABASE
```


## License

See LICENSE.

```text
Copyright (C) 2019 Lupine Software LLC

This is free software;
You can redistribute it and/or modify it under the terms of
the GNU Affero General Public License (AGPL).
```
