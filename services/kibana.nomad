job "kibana" {
  datacenters = ["dc1"]

  type = "service"

  group "kibana" {
    count = 1

    network {
      mode= "bridge"

      port "http" {
        static = 5601
        to = 5601
      }
    }

    service {
      name = "kibana"
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "elasticsearch"
              local_bind_port  = 9200
            }
            config {
              bind_address = "0.0.0.0"
            }
          }
        }
      }
    }

    task "kibana" {
      driver = "docker"

      env {
        ELASTICSEARCH_HOSTS="http://${NOMAD_UPSTREAM_ADDR_elasticsearch}"
      }

      config {
        image = "docker.elastic.co/kibana/kibana-oss:6.7.1"
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}

