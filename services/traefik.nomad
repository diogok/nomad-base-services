job "traefik" {
  datacenters = ["dc1"]

  type = "system"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    auto_revert = true
    canary = 1
  }

  group "traefik" {
    count = 1

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v1.7.10-alpine"

        port_map {
          proxy=80
          admin=8080
        }

        network_mode="weave"
        dns_servers=["172.17.0.1"]
        extra_hosts=["host:10.2.2.1"]

        command="traefik"
        args=[
           "--api" ,
           "--consulCatalog",
           "--consulCatalog.watch=true",
           "--consulCatalog.prefix=traefik",
           "--consulCatalog.endpoint=10.2.2.1:8500",
           "--consulCatalog.exposedByDefault=false",
           "--metrics",
           "--metrics.prometheus",
           "--tracing",
           "--tracing.backend=jaeger",
           "--tracing.jaeger.samplingServerURL=http://jaeger-agent.weave.local:5778/sampling",
           "--tracing.jaeger.localAgentHostPort=jaeger-agent.weave.local:6831",
           "--accesslog.filepath="
        ]
      }

      resources {
        cpu    = 150
        memory = 128
        network {
          port "proxy" {
            static=80
          }
          port "admin" { 
            static=8080
          }
        }
      }

      service {
        name = "traefik-proxy"
        port = "proxy"
      }

      service {
        name = "traefik"
        port = "admin"
        address_mode="driver"

        tags=["prometheus"]

        check {
          name     = "traefik-admin-alive"
          type     = "http"
          interval = "20s"
          timeout  = "2s"
          path     = "/metrics"
          port     = "admin"
          address_mode="host"
        }
      }
    }
  }
}

