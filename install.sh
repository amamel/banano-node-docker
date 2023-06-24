#!/bin/bash

echo "== Cloning installation"
git -C /opt/banano-node-docker pull || git clone https://github.com/amamel/banano-node-docker.git /opt/banano-node-docker

echo "== Starting installation"
sudo bash /opt/banano-node-docker/bnd/banano.sh -s