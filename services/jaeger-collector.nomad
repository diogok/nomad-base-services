job "jaeger-collector" {
  datacenters = ["dc1"]

  type = "system"

  group "jaeger-collector" {
    count = 1

    task "jaeger-collector" {
      driver = "docker"

      env {
        SPAN_STORAGE_TYPE="elasticsearch"
        ES_SERVER_URLS="http://elasticsearch.weave.local:9200/"
      }

      config {
        image = "jaegertracing/jaeger-collector:1.11"

        network_mode="weave"
        hostname="jaeger-collector.weave.local"
        #dns_search_domains=".weave.local."
        dns_servers=["172.17.0.1"]

        port_map = {
          tchannel=14267
          http=14268
        }
      }

      resources {
        cpu    = 100
        memory = 56

        network {
          port "tchannel" { }
          port "http" { }
        }
      }

      service {
        name = "jaeger-collector-http"
        port = "http"
        address_mode="driver"

        tags=["prometheus"]

        check {
          name     = "jaeger-collector-http"
          port     = "http"
          type     = "http"
          interval = "10s"
          timeout  = "2s"
          path     = "/metrics"
        }
      }
    }
  }
}


