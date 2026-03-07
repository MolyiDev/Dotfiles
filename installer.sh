#!/usr/bin/env bash
set -euo pipefail
trap 'echo -e "\n[x] Error on line $LINENO: $BASH_COMMAND" >&2' ERR

### Variables ###
WINDOW_MANAGER="bspwm" # Choose Hyprland / Niri / Sway / bspwm

REPO_URL="https://github.com/MolyiEZ/Dotfiles"

### Helpers ###
have_cmd() { command -v "$1" >/dev/null 2>&1; }
say() { printf "\033[1;32m[*]\033[0m %s\n" "$*"; }

# Lower case
WINDOW_MANAGER="${WINDOW_MANAGER,,}"

### Packages ###
PKGS_COMMON=(
    base-devel git curl wget rsync tar xz fbset flatpak
    7zip eza fd fzf ripgrep yq tmux nvim yazi npm unrar unzip gvfs jq xdg-user-dirs
    zsh zsh-syntax-highlighting
    ttf-jetbrains-mono ttf-jetbrains-mono-nerd otf-codenewroman-nerd
    vim-spell-en vim-spell-es
    nwg-look
    vlc vlc-plugins-all gimp xournalpp
    thunar tumbler baobab pavucontrol
    discord steam gamemode
)

AUR_COMMON=(
    zsh-theme-powerlevel10k-git
    papirus-folders
    awatcher-bundle
    zen-browser-bin
    localsend-bin
    qimgv-git
    vinegar-git
)

FLATPAKS_COMMON=(
    org.gnome.Calculator
    org.vinegarhq.Sober
    com.stremio.Stremio
)

PKGS_WM=()
AUR_WM=()
PKGS_REMOVE=()

case "$WINDOW_MANAGER" in
    "bspwm")
        PKGS_WM=(
            bspwm
            sxhkd alacritty rofi polybar feh maim
            xdg-desktop-portal-gtk xclip xdotool
            xorg-server xorg-xev xorg-xinit xorg-xinput xorg-xset xorg-xsetroot
            xss-lock snixembed
        )
        AUR_WM=( i3lock-color xidlehook )
        ;;

    "sway")
        PKGS_WM=( sway swww )
        AUR_WM=( swaylock-effects )
        PKGS_REMOVE=( alacritty swaylock )
        ;;

    "hyprland")
        PKGS_WM=( hyprland hypridle hyprlock hyprpaper hyprshot meson cpio )
        PKGS_REMOVE=( kitty dolphin )
        ;;

    "niri")
        PKGS_WM=( niri swww xwayland-satellite )
        AUR_WM=( swaylock-effects )
        PKGS_REMOVE=( alacritty swaylock )
        ;;
    *)
        echo "Unknown WINDOW_MANAGER: $WINDOW_MANAGER | Change it to one of these options: 'Hyprland' / 'Niri' / 'Sway' / 'bspwm'"
        exit 1
        ;;
esac

### Execution ###
# Check if is root user
if [[ $EUID -eq 0 ]]; then
    echo "Error: Run as a normal user, not root (yay/makepkg will fail)."
    exit 1
fi

# Request root
sudo -v || { echo "Need sudo to continue."; exit 1; }

# Refresh mirrors & update system
say "Updating system..."
sudo pacman -Syyu --needed --noconfirm archlinux-keyring

# Remove packages
if [ ${#PKGS_REMOVE[@]} -gt 0 ]; then
    say "Removing packages for $WINDOW_MANAGER..."
    if installed_pkgs=$(pacman -Qsq "${PKGS_REMOVE[@]}" 2>/dev/null); then
        sudo pacman -Rns --noconfirm $installed_pkgs
    fi
fi

# Install Yay
if ! have_cmd yay; then
    say "Installing yay..."
    tmpdir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    pushd "$tmpdir/yay-bin" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null
    rm -rf "$tmpdir"
fi

# Install Packages
say "Installing Common Packages..."
sudo pacman -S --needed --noconfirm "${PKGS_COMMON[@]}"

say "Installing $WINDOW_MANAGER Packages..."
if [ ${#PKGS_WM[@]} -gt 0 ]; then
    sudo pacman -S --needed --noconfirm "${PKGS_WM[@]}"
fi

say "Installing Flatpaks..."
for app in "${FLATPAKS_COMMON[@]}"; do
    flatpak install -y flathub "$app" || true
done

say "Installing AUR Packages..."
ALL_AUR=("${AUR_COMMON[@]}" "${AUR_WM[@]}")
yay -S --needed --noconfirm "${ALL_AUR[@]}"

# Tools
if ! have_cmd rojo; then
    say "Installing rojo..."
    # Export cargo (It was just installed)
    export PATH="$HOME/.cargo/bin:$PATH"
    cargo install rojo --version ^7
fi

# Dotfiles
say "Cloning dotfiles..."
TMP_CLONE="$(mktemp -d)"
git clone --depth=1 "$REPO_URL" "$TMP_CLONE"

say "Syncing config to $HOME..."
rsync -av --exclude "installer.sh" "$TMP_CLONE"/ "$HOME"/

# Services
say "Executing services script..."
service_script="$TMP_CLONE/services.sh"

if [[ -f "$service_script" ]]; then
    chmod +x "$service_script"
    "$service_script"
else
    say "Services script not found, skipping."
fi

# Delete the dotfiles folder
rm -rf "$TMP_CLONE"

# Scripts
say "Making scripts executable..."

# Find any folder named 'scripts' (case insensitive) in .config
# and make all files inside them executable.
find "$HOME/.config" -type d -iname "scripts" -print0 | while IFS= read -r -d '' dir; do
    say "  > +x files in: $dir"
    chmod +x "$dir"/* 2>/dev/null || true
done

# Specific scripts per window manager
case "$WINDOW_MANAGER" in
    "bspwm")
        say "  > +x bspwmrc, sxhkdrc & polybar launch"
        chmod +x "$HOME/.config/bspwm/bspwmrc" 2>/dev/null || true
        chmod +x "$HOME/.config/sxhkd/sxhkdrc" 2>/dev/null || true
        chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null || true
        ;;
esac

# Tmux plugin manager
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    say "Installing tmux plugin manager..."
    git clone "https://github.com/tmux-plugins/tpm" "$TPM_DIR"
fi

# Default shell -> zsh
if [[ "${SHELL##*/}" != "zsh" ]]; then
    say "Changing shell to zsh..."
    chsh -s "$(command -v zsh)" "$USER"
fi

# Papirus dark folders
say "Applying Papirus dark theme..."
papirus-folders -C black --theme Papirus-Dark


# Reboot
read -r -p "Setup complete. Reboot now? [Y/n] " ans
if [[ "${ans:-N}" =~ ^[Yy]$ ]]; then
    systemctl reboot
fi
