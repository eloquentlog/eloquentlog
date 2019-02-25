# Eloquentlog

## Note

### Setup

#### Nodes & Networks

```zsh
% make up

# create/delete nodes
% make join
% make leave
```

#### Containers

##### Visualizer

This is optional.

```zsh
# visualizer
% docker container exec -it eloquentlog-manager docker stack deploy \
  -c ./stack/visualizer.yml visualizer
```

Then, the visualizer will be up at `localhost:9000`.

##### PostgreSQL

```zsh
# build a data container and push it on local (dind) registry
% make data
```

```zsh
% make deploy:postgresql
Creating service eloquentlog-postgresql_data
Creating service eloquentlog-postgresql_master
Creating service eloquentlog-postgresql_slave
```

###### Display containers

```zsh
# display containers `<node> <name>.<id>` for master
% docker container exec -it eloquentlog-manager docker service ps \
  eloquentlog-data_master --no-trunc --filter "desired-state=running" \
  --format "{{.Node}} {{.Name}}.{{.ID}}"

# display containers `<node> <name>.<id>` for slave
% docker container exec -it eloquentlog-manager docker service ps \
  eloquentlog-data_slave --no-trunc --filter "desired-state=running" \
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
