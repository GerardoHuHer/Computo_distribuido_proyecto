#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

apt-get update
# apt-get upgrade -y -o Dpkg::Options::="--force-confold"
apt-get install -y docker.io

systemctl enable docker --now
usermod -aG docker vagrant

# Arreglo del backspace: si la VM no conoce el TERM del host, usar xterm-256color
LINEA='infocmp "$TERM" >/dev/null 2>&1 || export TERM=xterm-256color'
for rc in /home/vagrant/.bashrc /home/vagrant/.zshrc; do
  touch "$rc"
  grep -qxF "$LINEA" "$rc" || echo "$LINEA" >> "$rc"
  chown vagrant:vagrant "$rc"
done