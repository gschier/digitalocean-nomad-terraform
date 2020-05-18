variable "region" {}
variable "resource_tag" {}
variable "vpc_id" { }

resource "digitalocean_database_cluster" "database" {
  name       = "nomad-db"
  region     = var.region
  node_count = 1
  version    = "11"
  engine     = "pg"
  size       = "db-s-1vcpu-1gb"
  tags       = [var.resource_tag]
  private_network_uuid = var.vpc_id
}

