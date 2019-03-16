# PostgreSQL

This uses a official PostgreSQL container based on Alpine Linux.

[`postgres:alpine`](https://hub.docker.com/_/postgres/)


## volume for quick testing

```sh
docker volume create postgre_data
```

bind mount to host filesystem for actual stuff (docker volumes are a pain in the ass to maintain and manage)

## expose to localhost

(may conflict with already running PostgreSQL on localhost)

```sh
docker run -d -p 127.0.0.1:5432:5432 \
    --name postgres \
    -v postgre_data:/var/lib/postgresql/data \
    -e POSTGRES_PASSWORD=postgres \
    -e POSTGRES_USER=postgres \
    postgres:alpine
```

## on dedicated subnet

```sh
docker run -d --net docker1 --ip subnet-ip \
    --name postgres \
    -v postgre_data:/var/lib/postgresql/data \
    -e POSTGRES_PASSWORD=postgres \
    -e POSTGRES_USER=postgres \
    postgres:alpine
```
