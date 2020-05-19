variable "ssh_fingerprint" {}
variable "cluster_size" {}
variable "datacenter" {}
variable "region" {}
variable "vpc_id" {}
variable "resource_tag" {}

# Create a new Web Droplet
resource "digitalocean_droplet" "server" {
  count              = var.cluster_size
  name               = "nomad-cluster-${count.index + 1}"
  image              = "ubuntu-18-04-x64"
  region             = var.region
  size               = "1gb"
  private_networking = true
  backups            = true
  ssh_keys           = [var.ssh_fingerprint]
  tags               = [var.resource_tag]
  vpc_uuid           = var.vpc_id

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
  # Install Vault #
  # ~~~~~~~~~~~~~ #

  provisioner "remote-exec" {
    inline = ["mkdir -p /etc/vault.d /opt/vault"]
  }
  provisioner "file" {
    source      = "${path.root}/scripts/vault/install_vault.sh"
    destination = "/tmp/install_vault.sh"
  }
  provisioner "file" {
    source      = "${path.root}/scripts/vault/vault.hcl"
    destination = "/etc/vault.d/vault.hcl"
  }
  provisioner "file" {
    source      = "${path.root}/scripts/vault/vault.service"
    destination = "/etc/systemd/system/vault.service"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_vault.sh",
      "sed -i 's/__SERVER_IP__/${self.ipv4_address_private}/g' /etc/vault.d/vault.hcl",
      "/tmp/install_vault.sh",
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
      "export NOMAD_ADDR=http://${digitalocean_droplet.server.0.ipv4_address_private}:4646",
      "nomad server join ${digitalocean_droplet.server.0.ipv4_address_private}",
    ]
  }

  # ~~~~~~~~~~~~~~~ #
  # Copy Nomad Jobs #
  # ~~~~~~~~~~~~~~~ #

  provisioner "file" {
    source      = "${path.root}/jobs/"
    destination = "/opt/nomad"
  }
}

resource "null_resource" "jobs" {
  depends_on = [
    digitalocean_droplet.server,
  ]

  connection {
    type  = "ssh"
    user  = "root"
    host  = digitalocean_droplet.server.0.ipv4_address
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "export NOMAD_ADDR=http://${digitalocean_droplet.server.0.ipv4_address_private}:4646",
      "nomad job run /opt/nomad/fabio.hcl",
      "nomad job run /opt/nomad/http-echo.hcl",
      //      "nomad job run /opt/nomad/prometheus.hcl",
    ]
  }
}

resource "null_resource" "scripts" {
  provisioner "local-exec" {
    command = <<CMD
rm -rf gen
mkdir -p gen
echo "Creating ./gen/tunnel.sh"

cat > ./gen/tunnel.sh <<EOF
#!/bin/bash
echo "Start SSH tunnel to ${digitalocean_droplet.server.0.ipv4_address}"
ssh -N \\
  -L 4646:${digitalocean_droplet.server.0.ipv4_address_private}:4646 \\
  -L 9998:${digitalocean_droplet.server.0.ipv4_address_private}:9998 \\
  -L 9999:${digitalocean_droplet.server.0.ipv4_address_private}:9999 \\
  -L 8200:${digitalocean_droplet.server.0.ipv4_address_private}:8200 \\
  -L 8500:localhost:8500 \\
  root@${digitalocean_droplet.server.0.ipv4_address}
EOF

cat > ./gen/ssh.sh <<EOF
#!/bin/bash
echo "Connecting to ${digitalocean_droplet.server.0.ipv4_address}..."
ssh root@${digitalocean_droplet.server.0.ipv4_address}
EOF

chmod +x gen/*

CMD
  }
}

output "server_ids" {
  value = digitalocean_droplet.server.*.id
}

output "nomad_ip" {
  value = digitalocean_droplet.server.0.ipv4_address
}

output "nomad_ip_private" {
  value = digitalocean_droplet.server.0.ipv4_address_private
}
