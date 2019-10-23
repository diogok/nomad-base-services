job "elasticsearch-metrics" {
  datacenters = ["dc1"]

  type="service"

  group "metrics" {
    count = 1

    network {
      mode= "bridge"
    }

    service {
      name = "elasticsearch-metrics"
      port = "9108"

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

    task "metrics" {
      driver = "docker"

      config {
        image = "justwatch/elasticsearch_exporter:1.0.2"
        args=[
           "-es.uri","http://${NOMAD_UPSTREAM_ADDR_elasticsearch}"
          ,"-es.all"
          ,"-es.indices"
        ]
      }

      resources {
        cpu    = 50
        memory = 56
      }
    }
  }
}