# Docker commands

## -- expose ports in Docker

`-p 127.0.0.1:host-port:container-port`


## -- mount container volumes to host filesystem

`-v /host/path:/container/path`


## -- mount volumes

`-v volume_name:/container/path`


## -- create network namespace

`docker network create --subnet=172.18.0.0/16 ns-name`


## -- custom network with static IP address

`--net ns-name --ip subnet-ip`


## -- transfer data between volumes and/or host filesystem

```sh
docker volume create new_name
docker run --rm -it -v random_long_hash:/from -v new_name:/to alpine ash -c "cd /from ; cp -av . /to"
docker volume rm random_long_hash
```


## -- garbage collect registry

`docker exec docker-registry /bin/registry garbage-collect /etc/docker/registry/config.yml`


## -- Docker in Docker

`docker run --privileged -d --name namespace-name docker:dind`


## -- VMware Tools in CoreOS

`docker run -d --net=host --privileged --name vmware-tools corfr/vmware-tools:latest`


## -- Arch Linux container sandbox

keep container for later:

```sh
docker run --name archlinux -td archlinux/base:latest
docker exec -it archlinux /bin/bash
```

remove container after exit:

```sh
docker run --rm -it --name archlinux-sandbox archlinux/base:latest /bin/bash
```
