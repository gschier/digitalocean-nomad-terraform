#! /bin/bash

echo "Installing Vault on server"

wget -q -O vault.zip https://releases.hashicorp.com/vault/1.4.1/vault_1.4.1_linux_amd64.zip
unzip -o vault.zip
mv vault /usr/local/bin/

# Setup autocomplete
vault -autocomplete-install
complete -C /usr/local/bin/vault vault

# Start vault as a service
systemctl enable vault.service
systemctl start vault.service
echo "Installation of Vault complete"
exit 0
