variable "region" {}

resource "digitalocean_vpc" "vcp" {
  name        = "nomad-vpc"
  description = "VPC for Nomad cluster"
  region      = var.region
}

output "vpc_id" {
  value = digitalocean_vpc.vcp.id
}
