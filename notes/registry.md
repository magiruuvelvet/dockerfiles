# Docker Registry

## localhost, for development and backing up images (insecure)

```sh
docker run -d --net docker1 --ip 172.18.0.4 \
    --name docker-registry \
    --restart unless-stopped \
    -v /docker/registry/data:/var/lib/registry \
    -v /docker/registry/config:/etc/docker/registry \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:80 \
    registry:2
```

## production

consult better guides on how to set this up correctly
