# GitLab

GitLab without Docker volumes; all data is bind mounted to the host filesystem.

[`gitlab/gitlab-ce:latest`](https://hub.docker.com/r/gitlab/gitlab-ce)

```sh
docker run -d --net docker1 --ip 172.18.0.30 \
    --name gitlab \
    --restart unless-stopped \
    -v /docker/volumes/gitlab/etc:/etc/gitlab \
    -v /docker/volumes/gitlab/var:/var/opt/gitlab \
    -v /docker/volumes/gitlab/log:/var/log/gitlab \
    gitlab/gitlab-ce:latest
```
