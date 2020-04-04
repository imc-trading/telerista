FROM golang:latest as builder

COPY certs/ /usr/local/share/ca-certificates
RUN update-ca-certificates
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
RUN go get -d github.com/influxdata/telegraf
WORKDIR "/go/src/github.com/influxdata/telegraf"
RUN git checkout v1.14.0
RUN go mod download
COPY all_inputs.go /go/src/github.com/influxdata/telegraf/plugins/inputs/all/all.go
COPY all_outputs.go /go/src/github.com/influxdata/telegraf/plugins/outputs/all/all.go
RUN make static

FROM alpine:3.9

COPY certs/ /usr/local/share/ca-certificates
COPY --from=builder /go/src/github.com/influxdata/telegraf/telegraf /usr/bin/telegraf
COPY telegraf.conf /etc/telegraf/telegraf.conf

RUN set -eux; \
    apk add --no-cache iputils ca-certificates net-snmp-tools procps lm_sensors tzdata; \
    update-ca-certificates; \
    chmod a+x /usr/bin/telegraf;

EXPOSE 8125/udp 8092/udp 8094

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
ENV GNMI_SERVER=localhost:6030 \
    LANZ_SERVER=localhost:50001 \
    INFLUX_DB=telegraf
CMD ["telegraf", "--config-directory", "/etc/telegraf/telegraf.d/"]
