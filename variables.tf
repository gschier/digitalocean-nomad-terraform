variable "do_token" {}
variable "ssh_fingerprint" {}
variable "subdomain" {}
variable "domain" {}

variable "cluster_size" {
  default = 3
}

variable "datacenter" {
  default = "dc1"
}

variable "region" {
  default = "sfo2"
}

variable "resource_tag" {
  default = "nomad-cluster"
}

