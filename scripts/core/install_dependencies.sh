#! /bin/bash

echo "Installing Ubuntu dependencies"

apt-get update
apt-get upgrade --yes > /dev/null
apt-get install --yes zip > /dev/null

exit 0
