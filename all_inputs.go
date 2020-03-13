package all

import (
    _ "github.com/influxdata/telegraf/plugins/inputs/cpu"
    _ "github.com/influxdata/telegraf/plugins/inputs/disk"
    _ "github.com/influxdata/telegraf/plugins/inputs/diskio"
    _ "github.com/influxdata/telegraf/plugins/inputs/kernel"
    _ "github.com/influxdata/telegraf/plugins/inputs/mem"
    _ "github.com/influxdata/telegraf/plugins/inputs/processes"
    _ "github.com/influxdata/telegraf/plugins/inputs/swap"
    _ "github.com/influxdata/telegraf/plugins/inputs/system"
    _ "github.com/influxdata/telegraf/plugins/inputs/net"
    _ "github.com/influxdata/telegraf/plugins/inputs/nstat"
    _ "github.com/influxdata/telegraf/plugins/inputs/internal"
    _ "github.com/influxdata/telegraf/plugins/inputs/lanz"
    _ "github.com/influxdata/telegraf/plugins/inputs/cisco_telemetry_gnmi"
 )
