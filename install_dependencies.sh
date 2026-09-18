#!/bin/bash

echo "Las dependencias necesarias son: \n1. Docker \n2. Make "
# Remove previous versions
sudo dnf remove docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-selinux \
  docker-engine-selinux \
  docker-engine

# Set up repositories
sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo

# Install docker engine
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start docker engine
sudo systemctl enable --now docker

#Check docker installation
sudo docker run hello-world

# Instalar make and gcc
sudo dnf install make gcc
