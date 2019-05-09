job "logrotate" {
  datacenters = ["dc1"]

  type="batch"

  periodic {
    cron             = "@daily"
    prohibit_overlap = true
  }

  group "logrotate" {
    count = 1

    task "logrotate" {
      driver = "docker"

      config {
        image = "bobrik/curator"

        entrypoint = [ "/usr/bin/curator_cli" ]

        network_mode="weave"
        args=[
          "--host","elasticsearch.weave.local"
          "delete_indices",
          "--filter_list" ,
          "[{\"filtertype\":\"age\",\"direction\":\"older\",\"source\":\"creation_date\",\"unit\":\"days\",\"unit_count\":30},{\"filtertype\":\"pattern\",\"kind\":\"prefix\",\"value\":\"logs-\"}]"
        ]
      }

      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}


