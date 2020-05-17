#! /bin/bash

echo "Installing Ubuntu dependencies"

apt-get update > /dev/null
apt-get install --yes zip docker.io > /dev/null

echo "Configuring Docker"
# NOTE: I'm not sure why this is here, or if it's needed, but I found it here:

sysctl -w net.ipv4.conf.docker0.route_localnet=1
iptables -t nat -I PREROUTING -i docker0 -d 172.17.0.1 -p tcp -j DNAT --to 127.0.0.1
iptables -t filter -I INPUT -i docker0 -d 127.0.0.1 -p tcp -j ACCEPT

exit 0
