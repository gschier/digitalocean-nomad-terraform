provider "digitalocean" {
  token = var.do_token
}

module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

module "droplet" {
  source          = "./modules/droplet"
  region          = var.region
  datacenter      = var.datacenter
  cluster_size    = var.cluster_size
  ssh_fingerprint = var.ssh_fingerprint
  resource_tag    = var.resource_tag
  vpc_id          = module.vpc.vpc_id
}

module "loadbalancer" {
  source       = "./modules/loadbalancer"
  region       = var.region
  vpc_id       = module.vpc.vpc_id
  resource_tag = var.resource_tag
  domain       = var.domain
  subdomain    = var.subdomain
}

module "firewall" {
  source          = "./modules/firewall"
  resource_tag    = var.resource_tag
  server_ids      = module.droplet.server_ids
  loadbalancer_id = module.loadbalancer.loadbalancer_id
}

module "database" {
  source       = "./modules/database"
  region       = var.region
  resource_tag = var.resource_tag
  vpc_id       = module.vpc.vpc_id
}
