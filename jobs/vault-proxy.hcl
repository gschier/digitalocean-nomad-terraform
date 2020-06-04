job "proxy.vault" {
  datacenters = [
    "dc1"
  ]

  type = "service"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "vaultproxy" {
    count = 1

    task "vaultproxy" {
      driver = "docker"

      config {
        image = "nginx"

        volumes = [
          "custom/default.conf:/etc/nginx/conf.d/default.conf"
        ]
      }

      template {
        data = <<EOH
          server {
            listen {{ env "NOMAD_PORT_nginx" }};
            server_name nginx.service.uiproxy;
            location / {
              proxy_pass http://10.120.16.2:8200;
            }
          }
        EOH
        destination = "custom/default.conf"
      }

      resources {
        memory = 128

        network {
          port "nginx" {}
        }
      }

      service {
        name = "vaultproxy"
        port = "nginx"

        tags = [
          "nginx",
          "web",
          "urlprefix-vault.schier.dev/",
        ]

        check {
          type = "tcp"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }
}
