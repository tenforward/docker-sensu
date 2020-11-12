# sensu-backend
#
ARG GO_VERSION=1.15
ARG ALPINE_VERSION=3.12
ARG SENSU_VERSION=6.1.2

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

COPY --from=build /go/sensu-go-${SENSU_VERSION}/sensu-backend /usr/local/bin/sensu-backend
COPY --from=build /go/sensu-go-${SENSU_VERSION}/sensu-agent /usr/local/bin/sensu-agent
COPY --from=build /go/sensu-go-${SENSU_VERSION}/sensuctl /usr/local/bin/sensuctl

CMD ["sensu-backend", "help"]