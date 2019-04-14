job "jaeger-ui" {
  datacenters = ["dc1"]

  type = "service"

  group "jaeger-ui" {
    count = 1

    task "jaeger-ui" {
      driver = "docker"

      env {
        SPAN_STORAGE_TYPE="elasticsearch"
        ES_SERVER_URLS="http://elasticsearch.weave.local:9200/"
        QUERY_BASE_PATH="/jaeger"
      }

      config {
        image = "jaegertracing/jaeger-query:1.11"

        network_mode="weave"
        hostname="jaeger-collector.weave.local"
        #dns_search_domains=".weave.local."
        dns_servers=["172.17.0.1"]

        port_map = {
          http=16686
        }
      }

      resources {
        cpu    = 100
        memory = 256

        network {
          port "http" {}
        }
      }

      service {
        name = "jaeger-ui"
        port = "http"
        address_mode="driver"

        tags =[
           "traefik.enable=true"
          ,"traefik.frontend.rule=PathPrefix:/jaeger/"
        ]

        check {
          name     = "jaeger-ui-alive"
          port     = "http"
          type     = "http"
          interval = "10s"
          timeout  = "2s"
          path     = "/"
        }
      }
    }
  }
}


