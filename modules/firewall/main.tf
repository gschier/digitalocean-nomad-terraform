variable "server_ids" {}
variable "loadbalancer_id" {}
variable "resource_tag" {}

resource "digitalocean_firewall" "web" {
  name        = "nomad-firewall"
  droplet_ids = var.server_ids

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol                  = "tcp"
    port_range                = "all"
    source_tags               = [var.resource_tag]
    source_load_balancer_uids = [var.loadbalancer_id]
  }

  inbound_rule {
    protocol                  = "udp"
    port_range                = "all"
    source_tags               = [var.resource_tag]
    source_load_balancer_uids = [var.loadbalancer_id]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
