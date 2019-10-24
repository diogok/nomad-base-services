job "jaeger-deps" {
  datacenters = ["dc1"]

  type = "batch"

  periodic {
    cron             = "* * * * *"
    prohibit_overlap = true
  }

  group "jaeger-deps" {
    count = 1

    network {
      mode= "bridge"
    }

    service {
      name = "jaeger-deps"
 
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

    task "jaeger-deps" {
      driver = "docker"

      env {
        STORAGE="elasticsearch"
        ES_NODES="http://${NOMAD_UPSTREAM_ADDR_elasticsearch}"
      }

      config {
        image = "jaegertracing/spark-dependencies:latest"
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}


