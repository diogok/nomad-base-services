job "grafana" {
  datacenters = ["dc1"]

  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    auto_revert = true
  }

  group "grafana" {
    count = 1

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 512
    }

    task "grafana" {
      driver = "docker"

      env {
	      GF_SERVER_ROOT_URL="/grafana/"
        GF_AUTH_ANONYMOUS_ENABLED="true"
        GF_AUTH_ANONYMOUS_ORG_NAME="Main Org."
        GF_AUTH_ANONYMOUS_ORG_ROLE="Editor"
        GF_DATABASE_URL="mysql://grafana:freakoutnow@grafana-mysql.weave.local:3306/grafana"
        PROMETHEUS_HOST="prometheus.weave.local"
        PROMETHEUS_PORT="9090"
      }

      config {
        image = "grafana/grafana:6.2.1"

        volumes =[
           "grafana_data:/var/lib/grafana"
          ,"grafana_provisioning:/etc/grafana/provisioning"
        ]

        port_map {
          http=3000
        }

        network_mode="weave"
        dns_servers=["172.17.0.1"]
      }

      artifact {
        source= "git::https://github.com/diogok/grafana-provisioning"
        destination = "grafana_provisioning"
        options {
          ref = "v0.0.1"
        }
      }

      user="root"

      logs {
        max_files     = 2
        max_file_size = 15
      }

      resources {
        cpu    = 750
        memory = 1024
        network {
          port "http" {}
        }
      }

      service {
        name = "grafana"
        port = "http"
        address_mode="driver"

        tags = [
           "prometheus"
          ,"traefik.enable=true"
          ,"traefik.frontend.rule=PathPrefixStrip:/grafana/"
        ]

        check {
          name     = "grafana-alive"
          type     = "http"
          interval = "10s"
          timeout  = "2s"
          path     = "/metrics"
          port     = "http"
          address_mode="host"
        }
      }
    }
  }
}

