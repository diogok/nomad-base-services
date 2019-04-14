job "consul-exporter" {
  datacenters = ["dc1"]

  type="service"

  update {
    max_parallel = 1
    auto_revert = true
  }

  group "consul-exporter" {
    count = 1

    task "consul-exporter" {
      driver = "docker"

      config {
        image = "prom/consul-exporter"

        network_mode="weave"
        extra_hosts=["host:10.2.3.1"]

        args=["--consul.server","host:8500"]

        port_map {
          web=9107
        }
      }

      resources {
        cpu    = 250
        memory = 128
        network {
          port "web" {}
        }
      }

      service {
        name = "consul-exporter"
        port = "web"
        address_mode="driver"

        tags=["prometheus"]

        check {
          name     = "consul_exporter_alive"
          type     = "http"
          interval = "20s"
          timeout  = "2s"
          path     = "/metrics"
          port     = "web"
          address_mode="host"
        }
      }
    }
  }
}

