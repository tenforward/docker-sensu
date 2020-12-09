# sensu-backend
#
ARG GO_VERSION=1.15
ARG ALPINE_VERSION=3.12
ARG SENSU_VERSION=6.1.2
ARG DUMB_INIT_VERSION=1.2.4

FROM golang:${GO_VERSION}-alpine as build
LABEL maintainer="KATOH Yasufumi <karma@jazz.email.ne.jp>"
ARG ALPINE_VERSION
ARG SENSU_VERSION

RUN wget https://github.com/sensu/sensu-go/archive/v${SENSU_VERSION}.tar.gz && \
    tar xvf v${SENSU_VERSION}.tar.gz && \
    cd sensu-go-${SENSU_VERSION} && \
    go build ./cmd/sensu-agent && \
    go build ./cmd/sensu-backend && \
    go build ./cmd/sensuctl

FROM alpine:$ALPINE_VERSION
ARG SENSU_VERSION

RUN mkdir -p /opt/sensu/bin
COPY --from=build /go/sensu-go-${SENSU_VERSION}/sensu-backend /opt/sensu/bin/sensu-backend
COPY --from=build /go/sensu-go-${SENSU_VERSION}/sensu-agent /opt/sensu/bin/sensu-agent
COPY --from=build /go/sensu-go-${SENSU_VERSION}/sensuctl /opt/sensu/bin/sensuctl

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.4/dumb-init_1.2.4_x86_64 /usr/bin/dumb-init

COPY entrypoint.sh /opt/sensu/bin/entrypoint.sh
RUN cd /usr/local/bin && \
    ln -sf /opt/sensu/bin/entrypoint.sh sensu-backend && \
    ln -sf /opt/sensu/bin/entrypoint.sh sensu-agent && \
    ln -sf /opt/sensu/bin/entrypoint.sh sensuctl && \
    chmod 755 /opt/sensu/bin/entrypoint.sh && \
    chmod 755 /usr/bin/dumb-init
