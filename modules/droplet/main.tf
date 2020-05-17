variable "ssh_fingerprint" {
  description = "SSH fingerprint to enable"
}

variable "cluster_size" {
  description = "Number of nodes to create"
}

variable "datacenter" {
  description = "Name of datacenter"
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

  # ~~~~~~~~~~~~~~ #
  # Install Consul #
  # ~~~~~~~~~~~~~~ #

  provisioner "remote-exec" {
    inline = ["mkdir -p /etc/consul.d /opt/consul"]
  }
  provisioner "file" {
    source      = "${path.root}/scripts/consul/install_consul.sh"
    destination = "/tmp/install_consul.sh"
  }
  provisioner "file" {
    source      = "${path.root}/scripts/consul/consul.hcl"
    destination = "/etc/consul.d/consul.hcl"
  }
  provisioner "file" {
    source      = "${path.root}/scripts/consul/consul.service"
    destination = "/etc/systemd/system/consul.service"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_consul.sh",
      "sed -i 's/__SERVER_IP__/${self.ipv4_address_private}/g' /etc/consul.d/consul.hcl",
      "sed -i 's/__CLUSTER_SIZE__/${var.cluster_size}/g' /etc/consul.d/consul.hcl",
      "sed -i 's/__DATACENTER__/${var.datacenter}/g' /etc/consul.d/consul.hcl",
      "/tmp/install_consul.sh",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "consul join ${digitalocean_droplet.server.0.ipv4_address_private}",
    ]
  }

  # ~~~~~~~~~~~~~ #
  # Install Nomad #
  # ~~~~~~~~~~~~~ #

  provisioner "remote-exec" {
    inline = ["mkdir -p /etc/nomad.d /opt/nomad"]
  }
  provisioner "file" {
    source      = "${path.root}/scripts/nomad/install_nomad.sh"
    destination = "/tmp/install_nomad.sh"
  }
  provisioner "file" {
    source      = "${path.root}/scripts/nomad/nomad.hcl"
    destination = "/etc/nomad.d/nomad.hcl"
  }
  provisioner "file" {
    source      = "${path.root}/scripts/nomad/nomad.service"
    destination = "/etc/systemd/system/nomad.service"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_nomad.sh",
      "sed -i 's/__SERVER_IP__/${self.ipv4_address_private}/g' /etc/nomad.d/nomad.hcl",
      "sed -i 's/__CLUSTER_SIZE__/${var.cluster_size}/g' /etc/nomad.d/nomad.hcl",
      "sed -i 's/__DATACENTER__/${var.datacenter}/g' /etc/nomad.d/nomad.hcl",
      "/tmp/install_nomad.sh",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "export NOMAD_ADDR=http://${self.ipv4_address_private}:4646",
      "nomad server join ${digitalocean_droplet.server.0.ipv4_address_private}",
    ]
  }
}

resource "null_resource" "server_script" {
  provisioner "local-exec" {
    command = "echo 'ssh -N -L 4646:${digitalocean_droplet.server.0.ipv4_address_private}:4646 -L 8500:localhost:8500 root@${digitalocean_droplet.server.0.ipv4_address}' > tunnel.sh"
  }
}

output "server_ids" {
  value = digitalocean_droplet.server.*.id
}
