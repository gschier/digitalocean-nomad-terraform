log_level  = "DEBUG"
data_dir   = "/opt/nomad"
bind_addr  = "__SERVER_IP__"
datacenter = "__DATACENTER__"

# Enable the server
server {
  enabled = true

  # Self-elect, should be 3 or 5 for production
  bootstrap_expect = __CLUSTER_SIZE__
}

# Enable a client on the same node
client {
  enabled = true
}

telemetry {
  collection_interval        = "1s"
  disable_hostname           = true
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
}
