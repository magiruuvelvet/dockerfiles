# Redis

This uses a official Redis container based on Alpine Linux..

[`redis:alpine`](https://hub.docker.com/_/redis/)


## volume for redis dump

```sh
docker volume create redis_data
```

## expose to localhost

(may conflict with already running Redis on localhost)

```sh
docker run -d -p 127.0.0.1:6379:6379 \
    --name redis \
    -v redis_data:/data \
    redis:alpine
```

## on dedicated subnet

```sh
docker run -d --net docker1 --ip subnet-ip \
    --name redis \
    -v redis_data:/data \
    redis:alpine
```
