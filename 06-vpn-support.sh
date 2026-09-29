#!/usr/bin/env bash
# 06-vpn-support.sh - VPN plugins/clients NetworkManager is missing on a fresh Ubuntu
set -euo pipefail

echo "==> [06-vpn] Installing VPN support packages"
sudo apt-get update -y
sudo apt-get install -y \
  network-manager-openvpn network-manager-openvpn-gnome \
  network-manager-l2tp network-manager-l2tp-gnome \
  network-manager-strongswan strongswan \
  wireguard wireguard-tools openvpn

cat <<'EOF'

============================================================
 IMPORTANT: This script installs VPN *clients/plugins* only.
 Actual VPN profile configs (server IP, credentials, certs)
 are NOT included and must be added manually:
   GUI: Settings > Network > VPN > "+"
   CLI examples (uncomment & edit):

 # OpenVPN (.ovpn file):
 # sudo nmcli connection import type openvpn file /path/to/vpn.ovpn

 # WireGuard (.conf file):
 # sudo nmcli connection import type wireguard file /path/to/wg0.conf
============================================================
EOF
echo "==> [06-vpn] Done."
