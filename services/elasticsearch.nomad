job "elasticsearch" {
  datacenters = ["dc1"]

  type = "service"

  group "elasticsearch" {
    count = 1

    network {
      mode= "bridge"
    }

    service {
      name = "elasticsearch"
      port = "9200"

      connect {
        sidecar_service {}
      }
    }

    task "elasticsearch" {
      driver = "docker"

      env {
        ES_JAVA_OPTS="-Xmx700m -Xms700m"
        http.host="0.0.0.0"
      }

      config {
        image = "docker.elastic.co/elasticsearch/elasticsearch-oss:6.7.1"
      }

      resources {
        cpu    = 500
        memory = 1024
      }
    }
  }
}
