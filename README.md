# Docker to Go!

Workshop about [docker](https://www.docker.com/) and [Dockerfile](https://docs.docker.com/engine/reference/builder/), [best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/). I'll use [go](https://golang.org/) language to demonstrate power of docker.

# What is docker?

* Container image format that follows [Open Container Initiative](https://opencontainers.org/)
* A method for building container **images** `Dockerfile` / `docker build`
* A method for managing container **images** `docker image ls`, etc..
* A method for sharing container **images** `docker push/pull`, etc..
* A method for run container **instances** `docker run`, etc..
* A method for managing container **instances** `docker container ls`, etc..

## **Image vs Container**

![Image is a Blueprint](https://i.pinimg.com/originals/61/5c/c8/615cc87b000c725739feb4f79995237f.jpg)

![Container is a House](https://static.turbosquid.com/Preview/2015/01/02__21_43_11/02.jpg898a8fe6-5250-44f3-bdb4-63ebaf5d0620Original.jpg)

# Why docker ?

![image](https://i1.wp.com/www.docker.com/blog/wp-content/uploads/Blog.-Are-containers-..VM-Image-1-1024x435.png?ssl=1)

```bash
$ uname -r
```

# How docker works ?

## **cGroups**

Linux kernel feature that **limits**, **accounts** for, and **isolates** the **resource usage**.

```bash
$ docker run --name demo --detach --rm --cpus=2 --cpu-shares=20 --memory=20M alpine sleep 1d
```

## **Namespace**

Linux kernel feature that partitions kernel resources so that **a set or processes** can have **indepened set or resources**.

Namespace Types:
* Mount
* **PID**
* net
* ipc
* UTS
* user

```bash
$ docker run --name c1 --detach --rm alpine sleep 1d
$ docker run --name c2 --detach --rm alpine sleep 2d

$ ps aux | grep sleep
$ docker exec c1 ps aux
$ docker exec c2 ps aux
$ docker stop c2

$ docker run --name c2 --detach --rm --pid container:c1 alpine sleep 2d

$ docker exec c1 ps
$ docker exec c2 ps
```

## **containerd**

CRT - Container runtime

```bash
$ ps faux
```


# Docker danger!

```bash
$ mkdir ~/top_secret
$ echo "File create by root" > ~/top_secret/file.txt
$ sudo chown -R root:root ~/top_secret/
$ rm -f ~/top_secret/file.txt

$ docker run --name demo --rm --detach --volume ~/top_secret/:/app alpine sleep 3d
$ docker exec demo ls -l /app
$ docker exec demo rm -f /app/file.txt
$ ls -l ~/top_secret
```

# Dockerfile - Blueprint

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