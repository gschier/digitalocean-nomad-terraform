variable "ssh_fingerprint" {
  description = "SSH fingerprint to enable"
}

variable "cluster_size" {
  description = "Number of nodes to create"
}

# Create a new Web Droplet
resource "digitalocean_droplet" "server" {
  count              = var.cluster_size
  name               = "nomad-box-${count.index + 1}"
  image              = "ubuntu-18-04-x64"
  region             = "sfo2"
  size               = "1gb"
  private_networking = true
  ssh_keys           = [var.ssh_fingerprint]
  tags               = ["nomad-box"]

  connection {
    type    = "ssh"
    user    = "root"
    host    = self.ipv4_address
    agent   = true
    timeout = "5m"
  }

  # Install core dependencies
  provisioner "remote-exec" {
    script = "${path.root}/scripts/core/install_dependencies.sh"
  }

  # Create directories
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/nomad.d /opt/nomad",
    ]
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

  # Install Nomad
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_nomad.sh",
      "sed -i 's/server_0_public_ip/${digitalocean_droplet.server.0.ipv4_address}/g' /etc/nomad.d/nomad.hcl",
      "sed -i 's/server_public_ip/${self.ipv4_address}/g' /etc/nomad.d/nomad.hcl",
      "sed -i 's/server_private_ip/${self.ipv4_address_private}/g' /etc/nomad.d/nomad.hcl",
      "sed -i 's/cluster_size/${var.cluster_size}/g' /etc/nomad.d/nomad.hcl",
      "/tmp/install_nomad.sh",
    ]
  }

  # Join Nomad servers (Fix for nomad not auto starting #1945)
  provisioner "remote-exec" {
    inline = [
      "export NOMAD_ADDR=http://${self.ipv4_address_private}:4646",
      "nomad server join ${digitalocean_droplet.server.0.ipv4_address_private}",
    ]
  }
}

//resource "null_resource" "server_join" {
//  provisioner "local-exec" {
//    command = <<CMD
//join() {
//  curl -X PUT ${digitalocean_droplet.server.0.ipv4_address}:4646/v1/agent/join?address=$1
//}
//join ${digitalocean_droplet.server.1.ipv4_address}
//join ${digitalocean_droplet.server.2.ipv4_address}
//CMD
//  }
//}

output "server_ids" {
  value = digitalocean_droplet.server.*.id
}
