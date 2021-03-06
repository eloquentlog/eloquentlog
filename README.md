<h2 style="font-family:monospace,courier;font-size:3em"><img align="left" src="var/img/wolf-paw.png?raw=true" height="36" width="36" alt="Eloquentlog">Eloquentlog</h2>

[![status](https://img.shields.io/badge/Status-Alpha-yellow.svg)](https://gitlab.com/eloquentlog/eloquentlog/tree/master)
[![license](https://img.shields.io/badge/License-AGPL--3.0--or--later-orange.svg)](https://gitlab.com/eloquentlog)
[![project chat](https://img.shields.io/badge/Chat-Join_Zulip-4ebfac.svg)](https://eloquentlog.zulipchat.com/)

A log processing software.

https://eloquentlog.com/


## Note

### Setup

#### Overview

```zsh
% make up
% make join

# deploy containers (WIP)
% make deploy:xxx
% make deploy:xxx
...
```

#### Prepare networks & nodes

```zsh
% make up

# to create/delete nodes
% make join
% make leave
```

After containers deployment (in next steps), check each nodes with:

```zsh
% make info
```

#### Deploy containers

##### 0. Visualizer (optional)

```zsh
# visualizer
% make deploy:visualizer
```

Then, the visualizer will be up at `localhost:9000`.

##### 1. PostgreSQL

```zsh
# build a data container and push it on local (dind) registry
% make deploy:data
```

```zsh
% make deploy:postgresql
Creating service eloquentlog-postgresql_data
Creating service eloquentlog-postgresql_master
Creating service eloquentlog-postgresql_slave
```

TODO: schema migration

```zsh
# master (see `make node:info`)
% docker container exec -it <node> \
  docker exec -it eloquentlog-postgresql_master.1.<id> \
  psql -U <USER> <DATABASE> \
  -f /var/lib/postgresql/schema/<MIGRATION-NAME>/<NAME>.sql
CREATE TYPE
CREATE TYPE
CREATE SEQUENCE
...
```

#### 2. Redis

```zsh
% make deploy:redis
Creating service eloquentlog-redis_master
Creating service eloquentlog-redis_slave
```

#### 3. Console API

TODO

#### 4. Web

TODO

#### 5. Ingest API

TODO


## License

```text
┏━╸╻  ┏━┓┏━┓╻ ╻┏━╸┏┓╻╺┳╸╻  ┏━┓┏━╸
┣╸ ┃  ┃ ┃┃┓┃┃ ┃┣╸ ┃┗┫ ┃ ┃  ┃ ┃┃╺┓
┗━╸┗━╸┗━┛┗┻┛┗━┛┗━╸╹ ╹ ╹ ┗━╸┗━┛┗━┛

Copyright (C) 2017-2021 Lupine Software LLC
```

`AGPL-3.0-or-later`

```text
This is free software;
You can redistribute it and/or modify it under the terms of
the GNU Affero General Public License (AGPL).

This is free software: You can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
```
