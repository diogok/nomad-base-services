job "prometheus" {
  datacenters = ["dc1"]

  type = "service"

  group "prometheus" {
    count = 1

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 10240
    }

    task "prometheus" {
      driver = "docker"
      user="root"

      config {
        image = "prom/prometheus:v2.8.1"

        network_mode="weave"
        hostname="prometheus.weave.local"
        dns_servers=["172.17.0.1"]
        extra_hosts=["host:10.2.3.1"]

        port_map {
          ui=9090
        }

        volumes =[
           "${NOMAD_ALLOC_DIR}/data:/prometheus"
          ,"${NOMAD_ALLOC_DIR}/prometheus:/etc/prometheus"
        ]

        args= ["--storage.tsdb.path","/prometheus","--config.file","/etc/prometheus/prometheus.yml"]
      }

      artifact {
        source = "https://gist.githubusercontent.com/diogok/a6b2501aefc5d951c1ca2112d0ac6f05/raw/8e2cd36d4fe357c4fec4324240e6b489734087fb/prometheus.yml"
        destination = "prometheus"
      }

      resources {
        cpu    = 500
        memory = 1536

        network {
          port "ui" {}
        }
      }

      service {
        name = "prometheus"
        port = "ui"
        address_mode="driver"

        tags = [
           "prometheus"
          ,"traefik.enable=true"
          ,"traefik.frontend.rule=PathPrefixStrip:/prometheus/"
        ]

        check {
          name     = "prometheus-alive"
          port     = "ui"
          type     = "http"
          interval = "10s"
          timeout  = "2s"
          path     = "/"
        }
      }
    }
  }
}

