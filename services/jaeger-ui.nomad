job "jaeger-ui" {
  datacenters = ["dc1"]

  type = "service"

  group "jaeger-ui" {
    count = 1

    network {
      mode= "bridge"
      port "http" {
        to=16686
      }
    }

    service {
      name = "jaeger-ui-connect"
 
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
      name = "jaeger-ui"
      port = "http"

      tags =[
         "traefik.enable=true"
        ,"traefik.frontend.rule=PathPrefix:/jaeger/"
      ]
    }

    task "jaeger-ui" {
      driver = "docker"

      env {
        SPAN_STORAGE_TYPE="elasticsearch"
        ES_SERVER_URLS="http://${NOMAD_UPSTREAM_ADDR_elasticsearch}"
        QUERY_BASE_PATH="/jaeger"
      }

      config {
        image = "jaegertracing/jaeger-query:1.14"
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}


