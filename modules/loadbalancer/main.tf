variable "region" {}
variable "vpc_id" {}
variable "resource_tag" {}
variable "domain" {}
variable "subdomain" {}

data "digitalocean_domain" "default" {
  name = var.domain
}

resource "digitalocean_certificate" "default" {
  name    = "${var.subdomain}.${var.domain}"
  type    = "lets_encrypt"
  domains = [
    "${var.subdomain}.${var.domain}"
  ]
}

resource "digitalocean_loadbalancer" "loadbalancer" {
  name                     = "nomad-loadbalancer"
  region                   = var.region
  algorithm                = "least_connections"
  redirect_http_to_https   = true
  enable_backend_keepalive = false
  enable_proxy_protocol    = false
  droplet_tag              = var.resource_tag
  vpc_uuid                 = var.vpc_id

  sticky_sessions {
    cookie_name        = "do_sess"
    cookie_ttl_seconds = 60
    type               = "cookies"
  }

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 9999 # Fabio
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 9999 # Fabio
    target_protocol = "http"

    certificate_id  = digitalocean_certificate.default.id
    tls_passthrough = false
  }

  # Simply check if the node is up
  healthcheck {
    port                     = 9998
    protocol                 = "http"
    path                     = "/"
    healthy_threshold        = 2
    unhealthy_threshold      = 2
    check_interval_seconds   = 10
    response_timeout_seconds = 10
  }
}

resource "digitalocean_record" "www_nomad" {
  domain = data.digitalocean_domain.default.name
  name   = "nomad"
  type   = "A"
  value  = digitalocean_loadbalancer.loadbalancer.ip
  ttl    = 60 # Short for debugging
}

output "loadbalancer_id" {
  value = digitalocean_loadbalancer.loadbalancer.id
}
