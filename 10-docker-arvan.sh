#!/usr/bin/env bash
# 10-docker-arvan.sh - Docker with Arvan Cloud registry mirrors (Iran-friendly).
#
# Two approaches:
#  A) Official docker apt repo via a mirror (fastest installs, needs a reachable mirror).
#  B) FALLBACK (most reliable/universal): install docker.io from Ubuntu's own repos,
#     then point Docker Hub pulls at Arvan's registry mirror in /etc/docker/daemon.json.
# This script uses (B) by default because it works on 22.04 & 24.04 even when
# download.docker.com is unreachable/slow from Iran.
set -euo pipefail

echo "==> [10-docker-docker] Removing old/conflicting docker packages"
for p in docker.io docker-doc docker-compose podman-docker containerd runc; do
  sudo apt-get remove -y "$p" 2>/dev/null || true
done

echo "==> [10-docker-docker] Installing docker.io from Ubuntu repos (fallback approach B)"
sudo apt-get update -y
sudo apt-get install -y docker.io docker-compose-v2 containerd

echo "==> [10-docker-docker] Writing /etc/docker/daemon.json with Arvan registry mirrors"
sudo install -d -m 0755 /etc/docker
if [ ! -f /etc/docker/daemon.json ] || [ -f /etc/docker/daemon.json ]; then
  # Back up any existing daemon.json before overwriting
  [ -f /etc/docker/daemon.json ] && sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak.$(date +%Y%m%d%H%M%S)
  sudo tee /etc/docker/daemon.json > /dev/null <<'JSON'
{
  "registry-mirrors": [
    "https://docker.arvancloud.ir",
    "https://arvancontainer.ir"
  ]
}
JSON
fi

echo "==> [10-docker-docker] Enabling docker service"
sudo systemctl enable --now docker

echo "==> [10-docker-docker] Adding user '$USER' to docker group (logout/login required)"
sudo usermod -aG docker "$USER"

echo "==> [10-docker-docker] Done. Restart docker after edits: sudo systemctl restart docker"
