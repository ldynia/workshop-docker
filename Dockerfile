# 1st stage - Build!
FROM golang:1.16 AS BUILDER

WORKDIR /go/src/app

COPY . /go/src/app

# Initialize module, install packages and create binary
RUN go mod init hello
RUN go mod tidy
RUN go build -o hello

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