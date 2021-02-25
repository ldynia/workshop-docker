# Hello Docker & Go

```bash
$ docker build -t go:demo .
$ docker run --rm go:demo
$ docker run --rm --name go-demo -d go:demo sleep 1d
$ docker exec go-demo ls -l /app
$ watch -n1 docker ps
```

## Labels

```Dockerfile
LABEL version="1.0.0"
LABEL developer="ldynia"
```

## Heartbeat

```Dockerfile
HEALTHCHECK CMD [ "/app/hello", "||", "exit", "1"]
```

# Security

## Read only file system

```Dockerfile
RUN chmod -w /
```

## Root privilege escalation

```Dockerfile
USER nobody
```

## Distroless

```Dockerfile
FROM gcr.io/distroless/base-debian10
```