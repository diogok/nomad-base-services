job "grafana-mysql" {
  datacenters = ["dc1"]

  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    auto_revert = true
  }

  group "db" {
    count = 1

    network {
      mode= "bridge"
    }

    service {
      name = "grafana-mysql"
      port = "3306"

      connect {
        sidecar_service {}
      }
    }

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

        volumes =["${NOMAD_ALLOC_DIR}/mysql_data:/var/lib/mysql"]
      }

      user="root"

      logs {
        max_files     = 2
        max_file_size = 15
      }

      resources {
        cpu    = 100
        memory = 512
      }
    } 
  }
}

