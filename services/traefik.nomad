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


    network {
      mode= "bridge"

      port "http" {
        to=80
        static=80
      }

      port "admin" {
        to=8080
        static=8080
      }
    }

    service {
      name = "traefik"
      port = "http"

      connect {
        sidecar_service {}
      }
    }

    service {
      name = "traefik-admin"
      port = "admin"
      tags=["prometheus"]
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v1.7.10-alpine"

        command="traefik"
        args=[
           "--api" ,
           "--consulCatalog",
           "--consulCatalog.watch=true",
           "--consulCatalog.prefix=traefik",
           "--consulCatalog.endpoint=${attr.unique.network.ip-address}:8500",
           "--consulCatalog.exposedByDefault=false",
           "--metrics",
           "--metrics.prometheus",
           "--tracing",
           "--tracing.backend=jaeger",
           "--tracing.jaeger.samplingServerURL=http://${attr.unique.network.ip-address}:5778/sampling",
           "--tracing.jaeger.localAgentHostPort=${attr.unique.network.ip-address}:6831",
           "--accesslog.filepath="
        ]
      }

      resources {
        cpu    = 150
        memory = 128
      }
    }
  }
}

