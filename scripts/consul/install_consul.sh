#! /bin/bash

echo "Installing Consul on server"

wget -q -O consul.zip https://releases.hashicorp.com/consul/1.7.3/consul_1.7.3_linux_amd64.zip
unzip -o consul.zip
mv consul /usr/local/bin/

# Setup autocomplete
consul -autocomplete-install
complete -C /usr/local/bin/consul consul

# Start consul as a service
systemctl enable consul.service
systemctl start consul.service
echo "Installation of Consul complete"
exit 0
