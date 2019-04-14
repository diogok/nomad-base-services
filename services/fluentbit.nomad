job "fluentbit" {
  datacenters = ["dc1"]

  type="system"

  group "fluentbit" {
    count = 1

    task "fluentbit" {
      driver = "docker"

      env {
        ES_HOST="elasticsearch.weave.local"
        ES_PORT="9200"
      }

      config {
        image = "diogok/fluentbit:v0.0.4"

        network_mode="weave"
        hostname="fluentbit.weave.local"
        dns_servers=["172.17.0.1"]

        port_map {
          json=5432
          syslog=9514
          syslog2=9515
          fluent=24224
          monitor=9600
        }
      }

      resources {
        cpu    = 500
        memory = 128
        network {
          port "json" { 
            static=5432
          }
          port "fluent" { 
            static=24224
          }
          port "syslog" { 
            static=9514
          }
          port "syslog2" { 
            static=9515
          }
          port "monitor" {}
        }
      }

      service {
        name = "fluentbit-api"
        port = "monitor"
        address_mode="driver"

        tags=[
           "prometheus"
          ,"prometheus.metrics_path=/api/v1/metrics/prometheus"
        ]

        check {
          name     = "fluentbit-api-alive"
          type     = "http"
          method    = "GET"
          path     = "/?pretty"
          interval = "10s"
          timeout  = "2s"
          port     = "monitor"
          address_mode="host"
        }
      }

      service {
        name = "fluentbit-syslog"
        port = "syslog"
        address_mode="host"
      }

      service {
        name = "fluentbit-json"
        port = "json"
        address_mode="host"
      }
    }
  }
}

