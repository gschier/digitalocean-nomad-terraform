provider "digitalocean" {
  token = var.do_token
}

module "firewall" {
  source = "./modules/firewall"
  server_ids = module.droplet.server_ids
}

module "droplet" {
  source = "./modules/droplet"
  ssh_fingerprint = var.ssh_fingerprint
  cluster_size = var.cluster_size
  datacenter = var.datacenter
}
