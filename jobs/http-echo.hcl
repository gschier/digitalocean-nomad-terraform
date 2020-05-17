job "http-echo" {
  datacenters = [ "dc1" ]

  group "echo" {
    count = 10

    update {
      canary       = 1
      max_parallel = 5
    }

    task "server" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo:latest"
        args  = [
          "-listen", ":${NOMAD_PORT_web}",
          "-text", "Hello World! ${NOMAD_IP_web}:${NOMAD_PORT_web}",
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

        tags = [ "urlprefix-/http-echo" ]

        check {
          type     = "http"
          path     = "/health"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
