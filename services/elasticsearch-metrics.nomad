job "elasticsearch-metrics" {
  datacenters = ["dc1"]

  type="service"

  group "metrics" {
    count = 1

    task "metrics" {
      driver = "docker"

      config {
        image = "justwatch/elasticsearch_exporter:1.0.2"

        port_map {
          metrics=9108
        }

        network_mode="weave"
        dns_servers=["172.17.0.1"]

        args=[
           "-es.uri","http://elasticsearch.weave.local:9200"
          ,"-es.all"
          ,"-es.indices"
        ]
      }

      resources {
        cpu    = 50
        memory = 56
        network {
          port "metrics" { }
        }
      }

      service {
        name = "es-metrics"
        port = "metrics"
        address_mode="driver"
        tags=["prometheus"]

        check {
          name     = "es-metrics-alive"
          type     = "http"
          interval = "20s"
          timeout  = "2s"
          port     = "metrics"
          path     = "/metrics"
          address_mode="host"
        }
      }
    }
  }
}


