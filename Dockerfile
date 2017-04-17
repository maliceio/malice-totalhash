FROM malice/alpine

LABEL maintainer "https://github.com/blacktop"

COPY . /go/src/github.com/maliceio/malice-totalhash
RUN apk --update add --no-cache ca-certificates
RUN apk --update add --no-cache -t .build-deps \
                                    build-base \
                                    mercurial \
                                    musl-dev \
                                    openssl \
                                    bash \
                                    wget \
                                    git \
                                    gcc \
                                    go \
  && echo "===> Building totalhash Go binary..." \
  && cd /go/src/github.com/maliceio/malice-totalhash \
  && export GOPATH=/go \
  && go version \
  && go get -d \
  && CGO_ENABLED=0 go build -ldflags "-X main.Version=$(cat VERSION) -X main.BuildTime=$(date -u +%Y%m%d)" -o /bin/totalhash \
  && rm -rf /go /usr/local/go /usr/lib/go /tmp/* \
  && apk del --purge .build-deps

WORKDIR /malware

ENTRYPOINT ["su-exec","malice","/sbin/tini","--","totalhash"]
CMD ["--help"]
