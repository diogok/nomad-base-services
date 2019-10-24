job "jaeger-agent" {
  datacenters = ["dc1"]

  type = "system"

  group "jaeger" {
    count = 1

    network {
      mode="bridge"

      port "http" {
        to=5778
        static=5778
      }

      port "thrift" {
        to=6831
        static=6831
      }
    }

    service {
      name = "jaeger-agent-metrics"
      port = "http"

      tags = ["prometheus"]

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "jaeger-collector-tchannel"
              local_bind_port  = 14267
            }
          }
        }
      }
    }

    task "jaeger-agent" {
      driver = "docker"

      config {
        image = "jaegertracing/jaeger-agent:1.14"

        args = ["--reporter.tchannel.host-port","${NOMAD_UPSTREAM_ADDR_jaeger_collector_tchannel}"]
      }

      resources {
        cpu    = 100
        memory = 56
      }
    }
  }
}


