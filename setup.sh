#!/bin/bash
set -e

# Colors
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'
C='\033[1;36m'; W='\033[1;37m'

CURR_DIR="$(cd "$(dirname "$0")" && pwd)"
UBUNTU_DIR="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"

banner() {
    clear
    cat <<- EOF
${Y}    _  _ ___  _  _ _  _ ___ _  _    _  _ ____ ___  
${C}    |  | |__] |  | |\ |  |  |  |    |\/| |  | |  \ 
${G}    |__| |__] |__| | \|  |  |__|    |  | |__| |__/ 

${G}     Modded Ubuntu V2 Installer${W}

EOF
}

log() { echo -e "${R}[${W}-${R}]${C} $1${W}"; }
ok()  { echo -e "${R}[${W}-${R}]${G} $1${W}"; }

package() {
    banner
    log "Checking required packages..."

    # Storage setup
    [ ! -d "$HOME/storage" ] && termux-setup-storage

    pkg update -y
    pkg upgrade -y
    pkg install -y pulseaudio proot-distro curl

    ok "Packages ready"
}

distro() {
    log "Checking Ubuntu distro..."

    if [ -d "$UBUNTU_DIR" ]; then
        ok "Ubuntu already installed"
        return
    fi

    proot-distro install ubuntu

    [ -d "$UBUNTU_DIR" ] && ok "Ubuntu installed successfully" || {
        log "Failed to install Ubuntu"
        exit 1
    }
}

sound() {
    log "Fixing sound..."

    cat > "$HOME/.sound" <<EOF
pulseaudio --start --exit-idle-time=-1
pacmd load-module module-aaudio-sink
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
EOF
}

setup_vnc() {
    log "Setting up VNC scripts..."

    install -Dm755 "$CURR_DIR/distro/vncstart" "$UBUNTU_DIR/usr/local/bin/vncstart"
    install -Dm755 "$CURR_DIR/distro/vncstop" "$UBUNTU_DIR/usr/local/bin/vncstop"
}

permission() {
    banner
    log "Setting up environment..."

    install -Dm755 "$CURR_DIR/distro/user.sh" "$UBUNTU_DIR/root/user.sh"

    setup_vnc

    # Timezone
    getprop persist.sys.timezone > "$UBUNTU_DIR/etc/timezone"

    # Ubuntu launcher
    cat > "$PREFIX/bin/ubuntu" <<EOF
proot-distro login ubuntu
EOF
    chmod +x "$PREFIX/bin/ubuntu"

    ok "Installation complete!"

    cat <<- EOF

${G}Ubuntu (CLI) installed successfully
${C}Restart Termux (important)

Then run:
  ubuntu
  bash user.sh

EOF
}

# Run
package
distro
sound
permission