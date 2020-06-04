# Terraform for Nomad on DigitalOcean

**NOTE: This is an experiment, please only use for reference**

```bash
# How to use
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

## Useful Things to Remember

- Consul UI runs on `:8500`
- Vault UI runs on `:8200`
- Nomad UI runs on `:4242`
- Fabio UI runs on `:9998` and proxies on `:9999`
