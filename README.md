# Eloquentlog

```txt
┏━╸╻  ┏━┓┏━┓╻ ╻┏━╸┏┓╻╺┳╸╻  ┏━┓┏━╸
┣╸ ┃  ┃ ┃┃┓┃┃ ┃┣╸ ┃┗┫ ┃ ┃  ┃ ┃┃╺┓
┗━╸┗━╸┗━┛┗┻┛┗━┛┗━╸╹ ╹ ╹ ┗━╸┗━┛┗━┛
```

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
% make deploy:visualizer
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
# display commands to each node
% make info:node
```

###### Create Schema

```zsh
# master (see `make info:node`)
% docker container exec -it <node> \
  docker exec -it eloquentlog-postgresql_master.1.<id> \
  psql -U USER DATABASE -f /var/lib/postgresql/schema/001.sql
CREATE TYPE
CREATE TYPE
CREATE SEQUENCE
...
```


## License

See LICENSE.

```text
┏━╸╻  ┏━┓┏━┓╻ ╻┏━╸┏┓╻╺┳╸╻  ┏━┓┏━╸
┣╸ ┃  ┃ ┃┃┓┃┃ ┃┣╸ ┃┗┫ ┃ ┃  ┃ ┃┃╺┓
┗━╸┗━╸┗━┛┗┻┛┗━┛┗━╸╹ ╹ ╹ ┗━╸┗━┛┗━┛

Copyright (C) 2019 Lupine Software LLC

This is free software;
You can redistribute it and/or modify it under the terms of
the GNU Affero General Public License (AGPL).
```
