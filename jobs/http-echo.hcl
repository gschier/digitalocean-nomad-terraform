job "app.http-echo" {
  datacenters = [
    "dc1"]

  group "echo" {
    count = 1

    update {
      canary = 1
      max_parallel = 5
      auto_promote = true
      auto_revert = true
      min_healthy_time = "5s"
      stagger = "10s"
      health_check = "checks"
    }

    task "server" {
      driver = "docker"

      template {
        data = <<EOH
{{ with secret "schier.co/database" }}
MESSAGE="{{key "url"}}"
{{ end }}
EOH
        env = true
        destination = "${NOMAD_SECRETS_DIR}/file.env"
        change_mode = "restart"
      }

      config {
        image = "hashicorp/http-echo:latest"
        args = [
          "-listen",
          ":${NOMAD_PORT_web}",
          "-text",
          "Hello World! ${NOMAD_IP_web}:${NOMAD_PORT_web} ${MESSAGE}",
        ]
      }

      resources {
        memory = 10
        network {
          mbits = 10
          port "web" {}
        }
      }

      service {
        name = "http-echo"
        port = "web"

        tags = [
          "urlprefix-schier.dev/"]

        check {
          type = "http"
          path = "/health"
          interval = "2s"
          timeout = "2s"
        }
      }
    }
  }
}
