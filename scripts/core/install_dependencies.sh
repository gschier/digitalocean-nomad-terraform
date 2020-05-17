#! /bin/bash

echo "Installing Ubuntu dependencies"

apt-get update > /dev/null
apt-get install --yes zip docker.io > /dev/null
exit 0
