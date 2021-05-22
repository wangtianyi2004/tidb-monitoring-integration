## setup go env

```
[root@r35 soft]# go env
GO111MODULE=""
GOARCH="amd64"
GOBIN="/opt/go/bin"
GOCACHE="/root/.cache/go-build"
GOENV="/root/.config/go/env"
GOEXE=""
GOFLAGS=""
GOHOSTARCH="amd64"
GOHOSTOS="linux"
GOINSECURE=""
GONOPROXY=""
GONOSUMDB=""
GOOS="linux"
GOPATH="/opt/go/goblog"
GOPRIVATE=""
GOPROXY="https://proxy.golang.org,direct"
GOROOT="/opt/go"
GOSUMDB="sum.golang.org"
GOTMPDIR=""
GOTOOLDIR="/opt/go/pkg/tool/linux_amd64"
GCCGO="gccgo"
AR="ar"
CC="gcc"
CXX="g++"
CGO_ENABLED="1"
GOMOD=""
CGO_CFLAGS="-g -O2"
CGO_CPPFLAGS=""
CGO_CXXFLAGS="-g -O2"
CGO_FFLAGS="-g -O2"
CGO_LDFLAGS="-g -O2"
PKG_CONFIG="pkg-config"
GOGCCFLAGS="-fPIC -m64 -pthread -fno-caret-diagnostics -Qunused-arguments -fmessage-length=0 -fdebug-prefix-map=/tmp/go-build605043882=/tmp/go-build -gno-record-gcc-switches"
```



## install prometheus-postgresql-adapter

```
## download prometheus-postgresql-adapter binary file
wget https://github.com/timescale/prometheus-postgresql-adapter/releases/download/v0.6.0/prometheus-postgresql-adapter-0.6.0-linux-amd64.tar.gz
tar vxzf prometheus-postgresql-adapter-0.6.0-linux-amd64.tar.gz
```



### install pg_prometheus

```
git clone https://github.com/timescale/pg_prometheus.git
cd pg_prometheus
make
make install

SELECT create_prometheus_table('metrics',use_timescaledb=>true);
```



### install TimescaleDB

```
postgres=# \dx
                                        List of installed extensions
     Name      |  Version  |   Schema   |                            Description
---------------+-----------+------------+-------------------------------------------------------------------
 pg_prometheus | 0.2.1     | public     | Prometheus metrics for PostgreSQL
 plpgsql       | 1.0       | pg_catalog | PL/pgSQL procedural language
 timescaledb   | 1.4.0-dev | public     | Enables scalable inserts and complex queries for time-series data
(3 rows)
```



## startup prometheus-postgresql-adapter service

```
./prometheus-postgresql-adapter \
-pg.host "192.168.12.35" \
-pg.port 5532 \
-pg.user "postgres" \
-pg.database "postgres" \
-pg.schema "public" \
-pg.table "metrics" \
-web.listen-address "192.168.159.35:9021" \
-log.level "debug" \
psql
```



## modify prometheus configuration file

```
[root@r35 conf]# cat prometheus.yml
---
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.
  evaluation_interval: 15s # By default, scrape targets every 15 seconds.
  # scrape_timeout is set to the global default (10s).
  external_labels:
    cluster: 'test-cluster'
    monitor: "prometheus"
remote_write:
- url: "http://192.168.159.35:9021/write"
```































