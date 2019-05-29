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
      }

      config {
        image = "grafana/grafana:6.2.1"

        volumes =[
           "${NOMAD_ALLOC_DIR}/grafana_data:/var/lib/grafana"
          ,"${NOMAD_ALLOC_DIR}/grafana_datasources:/etc/grafana/provisioning/datasources"
          ,"${NOMAD_ALLOC_DIR}/grafana_dashboards:/etc/grafana/provisioning/dashboards"
        ]

        port_map {
          http=3000
        }

        network_mode="weave"
        dns_servers=["172.17.0.1"]
      }

      artifact {
        source = "https://gist.githubusercontent.com/diogok/d1fbfb2f44715234eecb5fec2919c065/raw/c2ab2fda7d55722e4f23a46ab247742eb5ecb2ce/prometheus.yml"
        destination = "grafana_datasources"
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

