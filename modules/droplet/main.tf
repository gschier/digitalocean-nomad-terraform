variable "ssh_fingerprint" {
  description = "SSH fingerprint to enable"
}

variable "cluster_size" {
  description = "Number of nodes to create"
}

# Create a new Web Droplet
resource "digitalocean_droplet" "server" {
  count              = var.cluster_size
  name               = "box-${count.index + 1}"
  image              = "ubuntu-20-04-x64"
  region             = "sfo2"
  size               = "1gb"
  private_networking = true
  ssh_keys           = [var.ssh_fingerprint]

  connection {
    type = "ssh"
    user = "root"
    host = self.ipv4_address
    agent = true
  }

  # Create directories
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/nomad.d /opt/nomad",
    ]
  }

  # Install dependencies file
  provisioner "file" {
    source      = "${path.root}/scripts/core/install_dependencies.sh"
    destination = "/tmp/install_dependencies.sh"
  }

  # Nomad installer file
  provisioner "file" {
    source      = "${path.root}/scripts/nomad/install_nomad.sh"
    destination = "/tmp/install_nomad.sh"
  }

  # Nomad config file
  provisioner "file" {
    source      = "${path.root}/scripts/nomad/nomad.hcl"
    destination = "/etc/nomad.d/nomad.hcl"
  }

  # Nomad service file
  provisioner "file" {
    source      = "${path.root}/scripts/nomad/nomad.service"
    destination = "/etc/systemd/system/nomad.service"
  }

  # Install core dependencies
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_dependencies.sh",
      "/tmp/install_dependencies.sh",
    ]
  }

  # Install Nomad
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_nomad.sh",
      "sed -i 's/server_public_ip/${self.ipv4_address}/g' /etc/nomad.d/nomad.hcl",
      "sed -i 's/server_private_ip/${self.ipv4_address_private}/g' /etc/nomad.d/nomad.hcl",
      "sed -i 's/cluster_size/${var.cluster_size}/g' /etc/nomad.d/nomad.hcl",
      "/tmp/install_nomad.sh",
    ]
  }
}

output "server_ids" {
  value = digitalocean_droplet.server.*.id
}
