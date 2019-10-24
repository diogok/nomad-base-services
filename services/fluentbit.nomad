job "fluentbit" {
  datacenters = ["dc1"]

  type="system"

  group "fluentbit" {
    count = 1

    network {
      mode= "bridge"

      port "metrics" {
        to=9600
      }

      port "json" {
        static=5432
        to=5432
      }

      port "syslog" {
        to=9514
        static=9514

      }
      port "syslog2" {
        to=9515
        static=9515

      }
      port "fluent" {
        to=24224
        static=24224
      }
    }

    service {
      name = "fluentbit"
      port = "5432"

      tags = [
        "prometheus"
        ,"prometheus.metrics_path=/api/v1/metrics/prometheus"
      ]
 
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "elasticsearch"
              local_bind_port  = 9200
            }
          }
        }
      }
    }

    service {
      name = "fluentbit-metrics"
      port = "metrics"

      tags = ["prometheus"]
    }


    task "fluentbit" {
      driver = "docker"

      env {
        ES_HOST="${NOMAD_UPSTREAM_HOST_elasticsearch}"
        ES_PORT="${NOMAD_UPSTREAM_PORT_elasticsearch}"
      }

      config {
        image = "diogok/fluentbit:es-0.0.5"
      }

      resources {
        cpu    = 500
        memory = 128
      }
    }
  }
}

