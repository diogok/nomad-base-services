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

    network {
      mode= "bridge"

      port "http" {
        to=3000
      }
    }

    service {
      name = "grafana"
      port = "http"

      tags = [
         "prometheus"
        ,"traefik.enable=true"
        ,"traefik.frontend.rule=PathPrefixStrip:/grafana/"
      ]
 
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "grafana-mysql"
              local_bind_port  = 3306
            }
            upstreams {
              destination_name = "prometheus"
              local_bind_port  = 9090
            }
          }
        }
      }
    }

    task "grafana" {
      driver = "docker"

      env {
	      GF_SERVER_ROOT_URL="/grafana/"
        GF_AUTH_ANONYMOUS_ENABLED="true"
        GF_AUTH_ANONYMOUS_ORG_NAME="Main Org."
        GF_AUTH_ANONYMOUS_ORG_ROLE="Editor"
        GF_DATABASE_URL="mysql://grafana:freakoutnow@${NOMAD_UPSTREAM_ADDR_grafana_mysql}/grafana"
        PROMETHEUS_HOST="${NOMAD_UPSTREAM_IP_prometheus}"
        PROMETHEUS_PORT="${NOMAD_UPSTREAM_PORT_prometheus}"
      }

      config {
        image = "grafana/grafana:6.4.3"

        volumes =[
           "grafana_data:/var/lib/grafana"
          ,"grafana_provisioning:/etc/grafana/provisioning"
        ]
      }

      artifact {
        source= "git::https://github.com/diogok/grafana-provisioning"
        destination = "grafana_provisioning"
        options {
          ref = "v0.0.2"
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
      }
    }
  }
}

