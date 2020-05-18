# Terraform for Nomad on DigitalOcean

**NOTE: This is an experiment, please only use for reference**

```bash
# How to use
terraform init
terraform apply
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
- [ ] [Vault](https://www.vaultproject.io) for secret sharing
- [x] Example web service and [Fabio](https://fabiolb.net) Proxy for load balancing

## Useful Things to Remember

- Consul UI runs on `:8500`
- Nomad UI runs on `:4242`
- Fabio UI runs on `:9998` and proxies on `:9999`
- SSH tunnel `ssh -N -L "4646:${DROPLET_PRIVATE_IP}:4646" "root@${DROPLET_PUBLIC_IP}"`
