job "sys.uiproxy" {
  datacenters = [
    "dc1"]
  type = "service"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "uiproxy" {
    count = 1

    task "uiproxy" {
      driver = "docker"

      config {
        image = "nginx"

        port_map {
          http = 8080
        }

        volumes = [
          "custom/default.conf:/etc/nginx/conf.d/default.conf"
        ]
      }

      template {
        data = <<EOH
          server {
            listen 8080;
            server_name nginx.service.nomadui;
            location / {
              proxy_pass http://10.120.16.2:4646;
            }
          }
        EOH
        destination = "custom/default.conf"
      }

      resources {
        memory = 128

        network {
          port "http" {
            static = 8080
          }
        }
      }

      service {
        name = "nginx"
        tags = [
          "nginx",
          "web",
          "urlprefix-admin.schier.dev/"
        ]

        port = "http"
        check {
          type = "tcp"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }
}
