# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/opt/nomad"

bind_addr = "server_private_ip"

# Enable the server
server {
  enabled = true

  # Self-elect, should be 3 or 5 for production
  bootstrap_expect = cluster_size
}

# Enable a client on the same node
client {
  enabled = true
}
