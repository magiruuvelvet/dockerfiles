# Portainer

Portainer container for local workstation without authorization.

**Don't use for production!!**

# localhost expose (default port 9000)

```sh
docker run -d -p 127.0.0.1:9000:9000 \
    --name portainer \
    --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /docker/volumes/portainer:/data \
    portainer/portainer --no-auth --no-analytics
```


# dedicated subnet (port 80)

```sh
docker run -d --net docker1 --ip 172.18.0.5 \
    --name portainer \
    --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /docker/volumes/portainer:/data \
    portainer/portainer --no-auth --no-analytics --bind :80
```
