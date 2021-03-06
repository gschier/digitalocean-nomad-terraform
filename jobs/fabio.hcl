job "sys.fabio" {
  datacenters = [
    "dc1"]
  type = "system"

  update {
    canary = 1
    stagger = "1s"
    max_parallel = 1
  }

  group "fabio" {
    count = 1

    task "fabio" {
      driver = "exec"

      config {
        command = "fabio"
        args = [
          "-proxy.strategy=rr",
        ]
      }

      resources {
        memory = 100
      }

      artifact {
        source = "https://github.com/fabiolb/fabio/releases/download/v1.5.13/fabio-1.5.13-go1.13.4-linux_amd64"
        destination = "local/fabio"
        mode = "file"
      }
    }
  }
}
