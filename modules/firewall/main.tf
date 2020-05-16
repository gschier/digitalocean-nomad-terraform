variable "server_ids" {
  type        = list(string)
  description = "list of servers"
}

resource "digitalocean_firewall" "web" {
  name        = "firewall-1"
  droplet_ids = var.server_ids

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol   = "tcp"
    port_range = "8500"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol   = "tcp"
    port_range = "4646"
    source_addresses = ["0.0.0.0/0", "::/0"]
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
