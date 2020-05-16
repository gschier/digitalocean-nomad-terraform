# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/opt/nomad"

bind_addr = "server_ip" # edit to private network

advertise {
  # Edit to the private IP address.
  http = "server_ip:4646"
  rpc  = "server_ip:4647"
  serf = "server_ip:4648" # non-default ports may be specified
}

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
