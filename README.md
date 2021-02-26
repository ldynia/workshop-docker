# Docker to Go!

Workshop about Docker best practices demonstrating on go language.

```bash
$ docker build -t go:demo --build-arg VERSION=v1.1 .
$ docker image history go:demo
$ docker image inspect go:demo

$ docker run --rm go:demo
$ docker run --rm --name go-demo -d go:demo sleep 1d
$ docker exec go-demo ls -l /app
$ watch -n1 docker ps
```

### Multi-stage build

```Dockerfile
FROM golang:1.16 AS BUILDER
```

### Labels

```Dockerfile
ARG VERSION=v0.5.0
ENV VERSION=$VERSION

LABEL version=$VERSION
LABEL developer="ldynia"
```

## Heartbeat

```Dockerfile
HEALTHCHECK CMD [ "/app/hello", "||", "exit", "1"]
```

### Volumes

```Dockerfile
VOLUME /app/data
```

### Read only file system

```Dockerfile
RUN chmod -w /
```

### Root privilege escalation

```Dockerfile
USER nobody
```

### Distroless

```Dockerfile
FROM gcr.io/distroless/base-debian10
```

[django-distroless](https://github.com/ldynia/django-distroless)