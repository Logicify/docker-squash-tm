# squash-tm

## Configuration

You may whant to set the following environment variables:

DB_URL: jdbc:postgresql://DB-HOST:5432/DB-NAME
DB_USERNAME: user-name
DB_PASSWORD: your-password
DB_DIALECT: org.hibernate.dialect.PostgreSQLDialect
DB_DRIVER: org.postgresql.Driver

Also there are a few locations you may whant to mount as volumes:

```
/srv/squash-tm/tmp                         # Jetty tmp and work directory
/srv/squash-tm/bundles                     # Bundles directory
/srv/squash-tm/conf                        # Configurations directory
/srv/squash-tm/logs                        # Log directory
/srv/squash-tm/jettyhome                   # Jetty home directory
/srv/squash-tm/luceneindexes               # Lucene indexes directory
/srv/squash-tm/plugins                     # Plugins directory
```

## Preparation for the first run

If you are going to use Postgres database you need to prepare DB and schema.

Run bash command on this image/container. e.g:

```
docker run --rm -it logicify/squash-tm /bin/bash
```

and issue the following:

```
psql -h <DBHOST HERE> --user $DB_USER $DB_NAME < ../database-scripts/postgresql-full-install-version-1.12.0.RELEASE.sql
```

## Docker compose example

Here is an example of the configuration using docker compose. Which starts an app on the port ```8012``` using external postgres databse (separate container):

```
postgres:
  build: postgres:9.4.1
  expose:
    - 5432
  volumes:
    - ./data-postgres:/var/lib/postgresql/data


squashtm:
  image: logicify/squash-tm:latest
  ports:
    - "8012:8080"
  environment:
    DB_URL: jdbc:postgresql://postgres:5432/squashtm
    DB_USERNAME: squashtm
    DB_PASSWORD: your-password
    DB_DIALECT: org.hibernate.dialect.PostgreSQLDialect
    DB_DRIVER: org.postgresql.Driver
  links:
    - postgres:postgres
```
