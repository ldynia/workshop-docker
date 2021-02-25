# 1st Stage - build!
FROM golang:1.16 AS BUILDER

WORKDIR /go/src/app

COPY . /go/src/app

# Initialize module, install packages and create binary
RUN go mod init hello
RUN go mod tidy
RUN go build -o hello

CMD ["/go/src/app/hello"]


# 2st Stage - run!
FROM alpine:latest AS RUN

WORKDIR /app

COPY --from=BUILDER /go/src/app/hello /app/

RUN chmod -w /

HEALTHCHECK CMD [ "/app/hello", "||", "exit", "1"]

USER nobody

CMD ["/app/hello"]


# 3rd Stage - Image Hardening
FROM gcr.io/distroless/base-debian10

COPY --from=RUN /app/hello /

CMD ["/hello"]