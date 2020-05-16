#! /bin/bash
set -e

echo "Installing Ubuntu dependencies"

apt-get update &> /dev/null
apt-get upgrade --yes &> /dev/null
apt-get install --yes unzip

