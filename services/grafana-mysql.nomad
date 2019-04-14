job "grafana-mysql" {
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

    task "mysql" {
      driver = "docker"

      env {
        MARIADB_ROOT_PASSWORD="donthackthegibson"
        MARIADB_PASSWORD="freakoutnow"
        MARIADB_USER="grafana"
        MARIADB_DATABASE="grafana"
      }

      config {
        image = "mariadb/server:10.3.13"

        volumes =["${NOMAD_ALLOC_DIR}/mysql_data_x1:/var/lib/mysql"]

        port_map {
          mysql=3306
        }

        network_mode="weave"
        hostname="grafana-mysql.weave.local"

        #args=["--default-authentication-plugin=mysql_native_password"]
      }

      user="root"

      logs {
        max_files     = 2
        max_file_size = 15
      }

      resources {
        cpu    = 100
        memory = 512
        network {
          port "mysql" {}
        }
      }

      service {
        name = "grafana-mysql"
        port = "mysql"
        address_mode="driver"

        check {
          name     = "grafana-mysql-alive"
          type     = "tcp"
          port     = "mysql"
          address_mode="host"
          interval="10s"
          timeout="2s"
        }
      }
    } 
  }
}

