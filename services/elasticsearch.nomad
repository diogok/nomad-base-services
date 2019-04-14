job "elasticsearch" {
  datacenters = ["dc1"]

  type = "service"

  group "elasticsearch" {
    count = 1

    task "elasticsearch" {
      driver = "docker"

      env {
        ES_JAVA_OPTS="-Xmx700m -Xms700m"
        http.host="0.0.0.0"
      }

      config {
        image = "docker.elastic.co/elasticsearch/elasticsearch-oss:6.7.1"

        port_map = {
          http=9200
        }

        network_mode="weave"
        hostname="elasticsearch.weave.local"
      }

      resources {
        cpu    = 500
        memory = 750

        network {
          port "http" {}
        }
      }

      service {
        name = "elasticsearch"
        port = "http"
        address_mode="driver"

        tags =[
           "traefik.enable=true"
          ,"traefik.frontend.rule=PathPrefix:/elasticsearch/"
        ]

        check {
          name     = "elasticsearch-alive"
          port     = "http"
          type     = "http"
          address_mode="host"
          interval = "10s"
          timeout  = "2s"
          path     = "/"
        }
      }
    }
  }
}
