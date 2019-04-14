job "jaeger-deps" {
  datacenters = ["dc1"]

  type = "batch"

  periodic {
    cron             = "* * * * *"
    prohibit_overlap = true
  }

  group "jaeger-deps" {
    count = 1

    task "jaeger-deps" {
      driver = "docker"

      env {
        STORAGE="elasticsearch"
        ES_NODES="http://elasticsearch.weave.local:9200"
      }

      config {
        image = "jaegertracing/spark-dependencies:latest"
        network_mode="weave"
        dns_servers=["172.17.0.1"]
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}


