# Ubuntu Dev Setup Scripts

Modular, idempotent setup scripts for a fresh Ubuntu 22.04 / 24.04 machine,
tailored for a developer based in Iran (Docker Hub pulls go through Arvan mirrors).

## Run everything

```bash
chmod +x *.sh
./install-all.sh
```

It asks for sudo once up-front, runs all steps in order, continues past failures,
and prints a PASS/FAIL summary at the end.

## Run one step

```bash
chmod +x *.sh
./10-docker-arvan.sh    # or: bash 10-docker-arvan.sh
```

## What each script does

| Script | Purpose |
|---|---|
| 00-base.sh | apt update/upgrade, base CLI tools, `fdfind -> fd` symlink |
| 01-fonts.sh | Nerd Fonts: MesloLGS NF (4 variants) + JetBrainsMono Nerd Font, fontconfig cache refresh |
| 02-vim.sh | vim + minimal .vimrc (backs up, never overwrites) |
| 03-oh-my-zsh.sh | zsh (default shell), oh-my-zsh, autosuggestions + syntax-highlighting plugins, custom prompt |
| 04-python-virtualenv.sh | python3, pip, venv, pipx, virtualenvwrapper wired into .zshrc |
| 05-node-npx.sh | nvm + latest LTS node (npm/npx included) |
| 06-vpn-support.sh | OpenVPN/L2TP/IKEv2/WireGuard plugins for NetworkManager |
| 07-sublime-text.sh | Sublime Text 4 via official apt repo |
| 08-keepassxc.sh | KeePassXC password manager |
| 09-browsers.sh | Chrome (.deb) + Firefox (snap on 22.04+, see notes) |
| 10-docker-arvan.sh | Docker with Arvan registry mirrors + user in docker group |
| 11-cursor.sh | Cursor AI editor via npx installer (`npx @anysphere/cursor-appimage`), .desktop entry |
| 12-extras.sh | gh CLI, NVIDIA drivers (autoinstall if GPU detected), pre-commit, bat/eza, PyCharm Community Edition (snap), kubectl, k9s, helm, httpie, gnome-tweaks, flameshot, timeshift, ssh-agent snippet |

## Important notes

- **Fonts**: installs `MesloLGS NF` (Powerlevel10k recommended) and `JetBrainsMono Nerd Font` into `~/.local/share/fonts/`. Set your terminal font to MesloLGS NF for prompt glyphs to render cleanly.
- **VPN**: only *clients/plugins* are installed. Real profiles (server IP, credentials, certs) must be added manually: Settings > Network > VPN > "+", or `sudo nmcli connection import type openvpn file vpn.ovpn`.
- **Cursor**: uses `npx --yes @anysphere/cursor-appimage` (requires node/npx from 05-node-npx.sh); the AppImage is placed in ~/Applications with a `cursor` symlink and .desktop entry.
- **Firefox**: on Ubuntu 22.04+ Firefox is distributed as a snap; `apt install firefox` installs the snap transition package. This works seamlessly on both 22.04 and 24.04.
- **Docker/Arvan**: installs docker.io from Ubuntu repos, then sets `/etc/docker/daemon.json` with `https://docker.arvancloud.ir` registry mirror.
- All scripts are idempotent and create timestamped `.bak` backups before modifying existing dotfiles.

## Manual steps after running

1. **Log out & log back in** (or reboot) so that:
   - your default shell becomes zsh,
   - `docker` group membership takes effect (`docker ps` without sudo).
2. **Terminal font**: select `MesloLGS NF` in terminal preferences (Preferences > Profiles > Text > Custom font).
3. **Restart your terminal** or run `exec zsh` to load oh-my-zsh, nvm, and virtualenvwrapper.
4. Review `/etc/docker/daemon.json` and add more mirrors if needed, then `sudo systemctl restart docker`.
5. Import your VPN profiles manually (see 06 script message).
6. If Cursor doesn't launch, run with `--no-sandbox`.
7. **NVIDIA drivers**: if 12-extras.sh installed a driver, **reboot** so the new kernel module is loaded (`nvidia-smi`).
# ubuntu-setup
# ubuntu-setup
# ubuntu-setup
# ubuntu-setup
