FROM alpine:latest

RUN apk add --no-cache bash wget upx xz build-base git openssh-client perl \
  autoconf automake gettext

RUN git clone https://github.com/ruanformigoni/pv-static-musl.git

WORKDIR pv-static-musl

RUN ./build.sh
