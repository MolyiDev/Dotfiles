#!/usr/bin/env bash
set -euo pipefail
trap 'echo -e "\n[x] Error on line $LINENO: $BASH_COMMAND" >&2' ERR

SYSTEM_SRC="$HOME/.config/systemd/system"
USER_SRC="$HOME/.config/systemd/user"
SYSTEM_DEST="/etc/systemd/system"

say() { printf "\033[1;32m[*]\033[0m %s\n" "$*"; }

# System Services
if [ -d "$SYSTEM_SRC" ]; then
    say "Processing SYSTEM services from $SYSTEM_SRC..."

    # Enable services
    find "$SYSTEM_SRC" -type f \( -name "*.service" -o -name "*.target" -o -name "*.timer" \) | while read file_path; do
        file_name=$(basename "$file_path")
        dest_path="$SYSTEM_DEST/$file_name"

        # Delete
        if [ -f "$dest_path" ] || [ -L "$dest_path" ]; then
            if [[ "$file_name" == *.service || "$file_name" == *.timer ]]; then
                say "Disabling old system $file_name..."
                sudo systemctl disable "$file_name" 2>/dev/null || true
            fi

            say "Removing existing $file_name from destination..."
            sudo rm -f "$dest_path"
        fi

        # Copy
        say "Copying $file_name to $SYSTEM_DEST..."
        sudo cp "$file_path" "$dest_path"

        # Ownership
        sudo chown root:root "$dest_path"
        sudo chmod 644 "$dest_path"

        # Enable
        if [[ "$file_name" == *.service || "$file_name" == *.timer ]]; then
            say "Enabling $file_name..."
            sudo systemctl enable "$file_name"
        fi
    done
else
    say "WARNING: Service directory $SYSTEM_SRC not found. Skipping services."
fi

say "Reloading daemons..."
sudo systemctl daemon-reload
systemctl --user daemon-reload

# User Services
if [ -d "$USER_SRC" ]; then
    say "Processing USER services from $USER_SRC..."

    # Enable services
    find "$USER_SRC" -name "*.service" | while read file_path; do
        file_name=$(basename "$file_path")

        # Enable
        say "Enabling $file_name..."
        systemctl --user disable "$file_name" 2>/dev/null || true
        systemctl --user enable "$file_name"
    done
else
    say "WARNING: Service directory $USER_SRC not found. Skipping services."
fi

# UPS (NUT) Setup
if command -v upsc >/dev/null 2>&1; then
    say "Configuring NUT for the UPS..."

    # Driver config for the Lyonn CTB-1500AP (Megatec/Q1 over USB).
    sudo tee /etc/nut/ups.conf >/dev/null <<'EOF'
[ups]
    driver = nutdrv_qx
    port = auto
    vendorid = 0665
    productid = 5161
    desc = "Lyonn CTB-1500AP"
EOF

    # Local standalone mode.
    echo "MODE=standalone" | sudo tee /etc/nut/nut.conf >/dev/null

    # upsmon login and safe shutdown on low battery (added once).
    if ! sudo grep -q '^\[upsmon\]' /etc/nut/upsd.users 2>/dev/null; then
        say "Adding upsmon login and shutdown rule..."
        NUTPASS=$(head -c 24 /dev/urandom | base64 | tr -d '+/=\n' | cut -c1-24)
        printf '\n[upsmon]\n    password = %s\n    upsmon primary\n' "$NUTPASS" \
            | sudo tee -a /etc/nut/upsd.users >/dev/null
        sudo sed -i '/^MONITOR ups@localhost/d' /etc/nut/upsmon.conf
        printf '\nMONITOR ups@localhost 1 upsmon %s primary\nMINSUPPLIES 1\nSHUTDOWNCMD "/usr/bin/systemctl poweroff"\n' "$NUTPASS" \
            | sudo tee -a /etc/nut/upsmon.conf >/dev/null
    fi

    # Enable services (start on next boot).
    say "Enabling NUT services..."
    sudo systemctl enable nut-driver-enumerator.path nut-server.service nut-monitor.service
else
    say "NUT not installed, skipping UPS setup."
fi
