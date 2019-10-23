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

    network {
      mode= "bridge"
      port "http" {
        to = 9090
      }
    }

    service {
      name = "prometheus"
      port = "9090"
      
      connect {
        sidecar_service {}
      }
    }

    task "prometheus" {
      driver = "docker"
      user="root"

      config {
        image = "prom/prometheus:v2.13.1"
        args= ["--storage.tsdb.path","/local/data","--config.file","/local/prometheus.yml"]
      }

      resources {
        cpu    = 500
        memory = 2048
      }

      template {
        destination   = "local/prometheus.yml"
        change_mode   = "signal"
        change_signal = "SIGHUP"

        data = <<EOF
global:
  scrape_interval: 5s
scrape_configs:
  - job_name: 'services'
    consul_sd_configs:
      - server: '{{env "attr.unique.network.ip-address"}}:8500'
    relabel_configs:
      - source_labels: [__meta_consul_tags]
        regex: .*,prometheus,.*
        action: keep
      - source_labels: [__meta_consul_service]
        target_label: job
      - source_labels: [__meta_consul_tags]
        regex: .*,prometheus.metrics_path=([^,]+),.*
        replacement: '${1}'
        target_label: __metrics_path__
        EOF
      }
    }
  }
}
