#! /bin/bash
set -e

echo "Installing Ubuntu dependencies"

apt-get update
apt-get upgrade --yes
apt-get install --yes unzip

