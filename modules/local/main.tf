variable "nomad_ip" {
  type        = string
  description = "IP address of Nomad server"
}

variable "nomad_ip_private" {
  type        = string
  description = "IP address Nomad is bound to"
}

resource "null_resource" "scripts" {
  provisioner "local-exec" {
    command = <<CMD
rm -rf gen
mkdir -p gen
echo "Creating ./gen/tunnel.sh"

cat > ./gen/tunnel.sh <<EOF
#!/bin/bash
echo "Start SSH tunnel"
ssh -N \
  -L 4646:${var.nomad_ip_private}:4646 \\
  -L 9998:${var.nomad_ip_private}:9998 \\
  -L 8500:localhost:8500 \\
  root@167.71.113.246
EOF

cat > ./gen/ssh.sh <<EOF
#!/bin/bash
echo "Connecting..."
ssh root@167.71.113.246
EOF

chmod +x gen/*

CMD
  }
}
