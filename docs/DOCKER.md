## Building a docker container

There is a sample [Dockerfile](/docker/Dockerfile) available.

Bulding:
--------

Build it using:

```
cd docker
docker build -t evcenter:latest .
```

Running:
--------

To run the container, use:

```
docker run --rm -it -e EVCENTER_DBHOST=<DBHOST> -p 3000:3000 evcenter:latest
```

Environment variables:
----------------------

The container accepts the following environment variables.

| Variable | Required | Default in image | Description |
|---|---|---|---|
| EVCENTER_MODE | No | production | Runtime mode. production starts starman. Any other value starts the Catalyst dev server with reload and debug flags. |
| EVCENTER_DBHOST | Yes (for real deployments) | localhost | PostgreSQL host for AuthDB and event models. |
| EVCENTER_DBNAME | Yes (for real deployments) | evcenter | PostgreSQL database name. |
| EVCENTER_DBUSER | Yes (for real deployments) | evcenter | PostgreSQL user. |
| EVCENTER_DBPASS | Yes (for real deployments) | evcenter | PostgreSQL password. |
| EVCENTER_DBPORT | No | 5432 | PostgreSQL port. |
| EVCENTER_DBOPTS | No | (empty) | Optional DBD::Pg DSN opts suffix appended as ;opts=... |
| PERL5LIB | No | ${PERL5LIB}:.:lib | Perl include path used by the container process. |

Notes:

- EVCENTER_DB* values are used from the environment by application configuration and model bootstrap code.
- In production you should always set at least EVCENTER_DBHOST, EVCENTER_DBNAME, EVCENTER_DBUSER and EVCENTER_DBPASS explicitly.

Examples:

Production mode:

```
docker run --rm -d \
	-e EVCENTER_MODE=production \
	-e EVCENTER_DBHOST=db \
	-e EVCENTER_DBNAME=evcenter \
	-e EVCENTER_DBUSER=evcenter \
	-e EVCENTER_DBPASS=secret \
	-e EVCENTER_DBPORT=5432 \
	-p 3000:3000 evcenter:latest
```

Development mode:

```
docker run --rm -d \
	-e EVCENTER_MODE=development \
	-e EVCENTER_DBHOST=db \
	-e EVCENTER_DBNAME=evcenter \
	-e EVCENTER_DBUSER=evcenter \
	-e EVCENTER_DBPASS=secret \
	-p 3000:3000 evcenter:latest
```