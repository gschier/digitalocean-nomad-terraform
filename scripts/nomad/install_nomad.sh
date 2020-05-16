#! /bin/bash
set -e

echo "Installing Nomad on server"

# Install nomad
wget -q -O nomad.zip https://releases.hashicorp.com/nomad/0.11.2/nomad_0.11.2_linux_amd64.zip
unzip nomad.zip
cp nomad /usr/bin/
mkdir -p /opt/nomad

# Start nomad as a service
systemctl enable nomad.service
systemctl start nomad.service
echo "Installation of Nomad complete"
exit 0
