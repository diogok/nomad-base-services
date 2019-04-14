job "kibana" {
  datacenters = ["dc1"]

  type = "service"

  group "kibana" {
    count = 1

    task "kibana" {
      driver = "docker"

      env {
        ELASTICSEARCH_URL="http://elasticsearch.weave.local:9200"
      }

      config {
        image = "docker.elastic.co/kibana/kibana-oss:6.3.1"

        network_mode="weave"
        dns_servers=["172.17.0.1"]

        port_map {
          ui=5601
        }
      }

      resources {
        cpu    = 100
        memory = 256

        network {
          port "ui" {}
        }
      }

      service {
        name = "kibana"
        port = "ui"
        address_mode="driver"

        tags =[
           "traefik.enable=true"
          ,"traefik.frontend.rule=Host:kibana.local"
        ]

        check {
          name     = "kibana-logs-alive"
          address_mode="host"
          port     = "ui"
          type     = "http"
          interval = "10s"
          timeout  = "2s"
          path     = "/"
        }
      }
    }
  }
}

