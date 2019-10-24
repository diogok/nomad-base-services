job "jaeger-collector" {
  datacenters = ["dc1"]

  type = "service"

  group "jaeger-collector" {
    count = 1

    network {
      mode= "bridge"

      port "http" {
        to=14268
      }
    }

    service {
      name = "jaeger-collector-metrics"
      port = "http"

      tags = ["prometheus"]
    }

    service {
      name = "jaeger-collector-tchannel"
      port = "14267"
 
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

    task "jaeger-collector" {
      driver = "docker"

      env {
        SPAN_STORAGE_TYPE="elasticsearch"
        ES_SERVER_URLS="http://${NOMAD_UPSTREAM_ADDR_elasticsearch}/"
      }

      config {
        image = "jaegertracing/jaeger-collector:1.14"
      }

      resources {
        cpu    = 100
        memory = 56
      }
    }
  }
}


