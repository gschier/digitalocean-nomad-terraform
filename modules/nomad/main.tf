variable "nomad_ip" {
  type        = string
  description = "IP adress of Nomad server"
}

variable "nomad_addr" {
  type        = string
  description = "Address bound to nomad"
}

resource "null_resource" "jobs" {
  provisioner "local-exec" {
    command = "ssh root@${var.nomad_ip} nomad job run -address=${var.nomad_addr} /opt/nomad/fabio.hcl"
  }
  provisioner "local-exec" {
    command = "ssh root@${var.nomad_ip} nomad job run -address=${var.nomad_addr} /opt/nomad/http-echo.hcl"
  }
}
