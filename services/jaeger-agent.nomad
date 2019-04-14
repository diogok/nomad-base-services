job "jaeger-agent" {
  datacenters = ["dc1"]

  type = "system"

  group "jaeger" {
    count = 1

    task "jaeger-agent" {
      driver = "docker"

      config {
        image = "jaegertracing/jaeger-agent:1.11"

        args = ["--reporter.tchannel.host-port","jaeger-collector.weave.local:14267"]

        network_mode="weave"
        hostname="jaeger-agent.weave.local"
        dns_servers=["172.17.0.1"]

        port_map = {
          zipkin=5775
          thriftc=6831
          thriftb=6832
          http=5778
        }
      }

      resources {
        cpu    = 100
        memory = 56

        network {
          port "grpc" {}
          port "zipkin" {}
          port "thriftc" {}
          port "thriftb" {}
          port "http" {}
        }
      }

      service {
        name = "jaeger-agent-http"
        port = "http"
        address_mode="driver"

        tags=["prometheus"]

        check {
          name     = "jaeger-agent-http"
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


