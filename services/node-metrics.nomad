job "node-exporter" {
  datacenters = ["dc1"]

  type="system"

  update {
    canary = 1
    max_parallel = 1
    auto_revert = true
  }

  group "nodee-xporter" {
    count = 1

    task "node-exporter" {
      driver = "docker"

      config {
        image = "quay.io/prometheus/node-exporter"

        network_mode="host"
        pid_mode="host"

        args=["--web.listen-address",":${NOMAD_PORT_web}"]
      }

      resources {
        cpu    = 120
        memory = 36
        network {
          port "web" {}
        }
      }

      service {
        name = "nodee-xporter"
        port = "web"
        address_mode="host"

        tags=["prometheus"]

        check {
          name     = "nodeexporter_alive"
          type     = "tcp"
          interval = "20s"
          timeout  = "2s"
          port     = "web"
          address_mode="host"
        }
      }
    }
  }
}

