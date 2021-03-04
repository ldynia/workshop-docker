# Docker to Go!

Workshop about [docker](https://www.docker.com/) and [Dockerfile](https://docs.docker.com/engine/reference/builder/), [best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/). I'll use [go](https://golang.org/) language to demonstrate power of docker.

**Requirements**:
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [docker](https://docs.docker.com/get-docker/)

# What is docker?

![docker archtecture](https://user-images.githubusercontent.com/1820831/109960922-a2791300-7ce9-11eb-8999-a6f05cf0eb1a.png)

* Container image format that follows [Open Container Initiative](https://opencontainers.org/)
* A method for building container **images** `Dockerfile` / `docker build`
* A method for managing container **images** `docker image ls`, etc..
* A method for sharing container **images** `docker push/pull`, etc..
* A method for run container **instances** `docker run`, etc..
* A method for managing container **instances** `docker container ls`, etc..

## **Image vs Container**

**Image = Dockerfile**
![Image is a Blueprint](https://i.pinimg.com/originals/61/5c/c8/615cc87b000c725739feb4f79995237f.jpg)

**No Process, No Container!**
![Container is a House](https://static.turbosquid.com/Preview/2015/01/02__21_43_11/02.jpg898a8fe6-5250-44f3-bdb4-63ebaf5d0620Original.jpg)

# Why docker ?

![image](https://i.ytimg.com/vi/TvnZTi_gaNc/maxresdefault.jpg)

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

$ docker exec c1 ps aux
$ docker exec c2 ps aux
$ ps aux | grep sleep
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

$ docker exec demo whoami
$ docker exec demo id
```

# Hello Go!


## Step 1 - Building hello go app

```bash
$ cd ~
$ git clone https://github.com/ldynia/workshop-docker.git
$ cd workshop-docker
```

`hello.go`
```go
package main

import (
	"fmt"
	"rsc.io/quote"
)

func main() {
	fmt.Println("Hello Go!")
	fmt.Println(quote.Go())
}
```

`Dockerfile` v1

```Dockerfile
FROM golang:1.16

WORKDIR /go/src/app

COPY . /go/src/app

# Initialize module, install packages and create binary
RUN go mod init hello && \
    go mod tidy && \
    go build -o hello

CMD ["/go/src/app/hello"]
```

```bash
$ docker build -t go/app .

$ docker image ls
$ docker image history go/app
$ docker image inspect go/app

$ docker run --name app go/app
$ docker ps -a
$ docker rm app
$ docker run --name app --rm go/app ls -lh /go/src/app
```

## Step 2 - Multi Stage build

`Dockerfile` v2

```Dockerfile
# 1st stage - Build!
FROM golang:1.16 AS BUILDER

WORKDIR /go/src/app

COPY . /go/src/app

# Initialize module, install packages and create binary
RUN go mod init hello && \
    go mod tidy && \
    go build -o hello

CMD ["/go/src/app/hello"]

# 2st stage - run!
FROM alpine:latest

WORKDIR /app

COPY --from=BUILDER /go/src/app/hello /app/

CMD ["/app/hello"]
```

```bash
$ docker run --name app --rm go/app
$ docker image ls | head -n 5
```

## Stage 3 - Health Check

`Dockerfile` v3
```Dockerfile
# 1st stage - Build!
FROM golang:1.16 AS BUILDER

WORKDIR /go/src/app

COPY . /go/src/app

# Initialize module, install packages and create binary
RUN go mod init hello && \
    go mod tidy && \
    go build -o hello

CMD ["/go/src/app/hello"]

# 2st stage - run!
FROM alpine:latest

WORKDIR /app

COPY --from=BUILDER /go/src/app/hello /app/

HEALTHCHECK CMD [ "/app/hello", "||", "exit", "1"]

CMD ["/app/hello"]
```

```bash
$ docker run --detach --rm --name app go/app sleep 1d
$ watch -n1 docker ps
```

### Step 4 - Read Only FS & Run as NON Root

`Dockerfile` v4
```Dockerfile
# 1st stage - Build!
FROM golang:1.16 AS BUILDER

WORKDIR /go/src/app

COPY . /go/src/app

# Initialize module, install packages and create binary
RUN go mod init hello && \
    go mod tidy && \
    go build -o hello

CMD ["/go/src/app/hello"]

# 2st stage - run!
FROM alpine:latest

WORKDIR /app

COPY --from=BUILDER /go/src/app/hello /app/

HEALTHCHECK CMD [ "/app/hello", "||", "exit", "1"]

RUN chmod -w /

USER nobody

CMD ["/app/hello"]
```

```bash
$ docker run --detach --rm --name app go/app sleep 1d
$ docker exec app whoami
$ docker exec app id
```

### Step 5 - Distroless

Example of [distroless django](https://github.com/ldynia/django-distroless) project.

`Dockerfile` v5
```Dockerfile
# 1st stage - Build!
FROM golang:1.16 AS BUILDER

WORKDIR /go/src/app

COPY . /go/src/app

# Initialize module, install packages and create binary
RUN go mod init hello && \
    go mod tidy && \
    go build -o hello

CMD ["/go/src/app/hello"]

# 2st stage - run!
FROM alpine:latest AS RUN

WORKDIR /app

COPY --from=BUILDER /go/src/app/hello /app/

HEALTHCHECK CMD [ "/app/hello", "||", "exit", "1"]

RUN chmod -w /

USER nobody

CMD ["/app/hello"]


# 3rd stage - fun!
FROM gcr.io/distroless/base-debian10

COPY --from=RUN /app/hello /

CMD ["/hello"]
```

```bash
$ docker run --rm --name app go/app whoami
$ docker run --rm --name app go/app sh
$ docker run --rm --name app go/app
```

### Step 6 - Volumes

`Dockerfile` v6
```Dockerfile
# 1st stage - Build!
FROM golang:1.16 AS BUILDER

WORKDIR /go/src/app

COPY . /go/src/app

# Initialize module, install packages and create binary
RUN go mod init hello && \
    go mod tidy && \
    go build -o hello

CMD ["/go/src/app/hello"]

# 2st stage - run!
FROM alpine:latest AS RUN

WORKDIR /app

COPY --from=BUILDER /go/src/app/hello /app/

HEALTHCHECK CMD [ "/app/hello", "||", "exit", "1"]

RUN chmod -w /

USER nobody

CMD ["/app/hello"]


# 3rd stage - fun!
FROM gcr.io/distroless/base-debian10

COPY --from=RUN /app/hello /

VOLUME /app/data

CMD ["/hello"]
```

### Step 7 - Args, Envars & Labels

`Dockerfile` v7
```Dockerfile
# 1st stage - Build!
FROM golang:1.16 AS BUILDER

WORKDIR /go/src/app

COPY . /go/src/app

# Initialize module, install packages and create binary
RUN go mod init hello && \
    go mod tidy && \
    go build -o hello

CMD ["/go/src/app/hello"]

# 2st stage - run!
FROM alpine:latest AS RUN

WORKDIR /app

COPY --from=BUILDER /go/src/app/hello /app/

HEALTHCHECK CMD [ "/app/hello", "||", "exit", "1"]

RUN chmod -w /

USER nobody

CMD ["/app/hello"]


# 3rd stage - fun!
FROM gcr.io/distroless/base-debian10

ARG VERSION=0.5
ENV VERSION=$VERSION

LABEL version=$VERSION

COPY --from=RUN /app/hello /

VOLUME /app/data

CMD ["/hello"]
```

```bash
$ docker build -t go/app --build-arg VERSION=v1.0 .
$ docker image history go/app
$ docker image inspect go/app
```

### Step 8 - .dockerignore

```bash
$ docker build -t go/app --build-arg VERSION=v1.0 .
Sending build context to Docker daemon   68.1kB
```

`.dockerignore` file
```
Dockerfile
*.md
```

```bash
$ docker build -t go/app --build-arg VERSION=v1.0 .
Sending build context to Docker daemon   59.9kB
```

## Dockerfile

Read **[Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)** document.


# Image Security

## Docker Bench Security

[docker bench security](https://github.com/docker/docker-bench-security) is security benchmark for best-practices around deploying Docker containers.

```bash
$ docker run --rm --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /etc:/etc:ro \
    -v /lib/systemd/system:/lib/systemd/system:ro \
    -v /usr/bin/containerd:/usr/bin/containerd:ro \
    -v /usr/bin/runc:/usr/bin/runc:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /var/lib:/var/lib:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --label docker_bench_security \
    docker/docker-bench-security
```

## Trivy

[Trivy](https://github.com/aquasecurity/trivy) is [CVE](https://cve.mitre.org/) scanner developed by aquasecurity.

```bash
$ mkdir /tmp/trivy
$ docker run --rm -v /tmp/trivy:/root/.cache/ aquasec/trivy python:3.4-alpine
$ docker run --rm -v /tmp/trivy:/root/.cache/ aquasec/trivy continuumio/miniconda3:4.8.2
$ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/trivy:/root/.cache/ aquasec/trivy django/pipelines
```
