FROM golang:1.13.4 as build
ENV GO111MODULE=on

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

COPY cmd/ cmd/
COPY pkg/ pkg/
COPY proto/ proto/
COPY Makefile Makefile

RUN make bin/kiam-linux-amd64

FROM ubuntu:bionic
RUN apt-get update
RUN DEBIAN_FRONTEND=non-interactive apt-get install \
    --yes --no-install-recommends \
    mtr-tiny dnsutils net-tools netcat iputils-ping && \
    apt-get clean
COPY --from=build /workspace/bin/kiam-linux-amd64 /kiam
CMD []
