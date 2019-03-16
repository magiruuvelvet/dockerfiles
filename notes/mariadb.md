# MariaDB

This uses a custom MariaDB container I made based on Alpine Linux to reduce disk usage.

For official containers use [`mariadb:latest`](https://hub.docker.com/_/mariadb/).


## volume for quick testing

```sh
docker volume create mariadb_data
```

bind mount to host filesystem for actual stuff (docker volumes are a pain in the ass to maintain and manage)

## expose to localhost

(may conflict with already running MariaDB on localhost)

```sh
docker run -d -p 127.0.0.1:3306:3306 \
    --name mariadb \
    -v mariadb_data:/var/lib/mysql \
    -e MARIADB_ROOT_PASSWORD=core \
    magiruuvelvet/alpine-mariadb:latest
```

## on dedicated subnet

```sh
docker run -d --net docker1 --ip subnet-ip \
    --name mariadb \
    -v mariadb_data:/var/lib/mysql \
    -e MARIADB_ROOT_PASSWORD=core \
    magiruuvelvet/alpine-mariadb:latest
```
