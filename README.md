# Terraform for Nomad on DigitalOcean

**NOTE: This is an experiment, please only use for reference**

```bash
# Bootstrap the cluster

terraform init
terraform apply

# A ./gen/ssh.sh and ./gen/tunnel.ssh will be generated with the 
# droplet IPs populated to help get started

./gen/ssh.sh      # To SHH into primary node
./gen/tunnel.ssh  # To start SSH tunnel for Nomad/Vault/Consul/Fabio UIs
```

You will be prompted for a DigitalOcean token, SSH fingerprint, and custer size (1, 3 or 5).

## Current Status

This currently installs the following:

- [x] DigitalOcean droplets
- [x] DigitalOcean firewall
- [x] DigitalOcean load balancer
- [x] DigitalOcean VPC
- [x] DigitalOcean DNS record
- [x] [Nomad](https://www.nomadproject.io) configured as both client/server
- [x] [Consul](https://www.consul.io) for client/server usage
- [x] [Vault](https://www.vaultproject.io) for secret sharing
- [x] Example web service and [Fabio](https://fabiolb.net) Proxy for load balancing

## Boostrapping Cluster

Here are the steps to get the cluster up and running:

1. Run `terraform init` and `terraform apply` to create initial resources
2. Initialize Vault with root token
3. Unseal Vault on each node
4. Set Vault token in each Nomad config file

## Upgrading Cluster

To upgrade the cluster, the following steps must be taken for each node:

1. Drain the Nomad client that will be upgraded
2. Promote a new server leader if the leader is the one being upgraded
3. Taint resource using Terraform
4. Apply single resource using Terraform
5. Set Vault token in Nomad config file
6. Unseal Vault on new node
