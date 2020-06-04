job "proxy.fabio" {
  datacenters = [
    "dc1"
  ]

  type = "service"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "fabioproxy" {
    count = 1

    task "fabioproxy" {
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
              proxy_pass http://10.120.16.2:9998;
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
        name = "fabioproxy"
        port = "nginx"

        tags = [
          "nginx",
          "web",
          "urlprefix-fabio.schier.dev/",
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
