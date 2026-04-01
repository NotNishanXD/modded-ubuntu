#!/bin/bash
set -e

# Colors
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'
C='\033[1;36m'; W='\033[1;37m'

banner() {
    clear
    cat <<- EOF
${Y}    _  _ ___  _  _ _  _ ___ _  _    _  _ ____ ___  
${C}    |  | |__] |  | |\ |  |  |  |    |\/| |  | |  \ 
${G}    |__| |__] |__| | \|  |  |__|    |  | |__| |__/ 

${G}     Modded Ubuntu V2 Remover${W}

EOF
}

log() { echo -e "${R}[${W}-${R}]${C} $1${W}"; }
ok()  { echo -e "${R}[${W}-${R}]${G} $1${W}"; }

remove_distro() {
    log "Removing Ubuntu distro..."

    if proot-distro list | grep -q ubuntu; then
        proot-distro remove ubuntu
        proot-distro clear-cache
        ok "Ubuntu removed"
    else
        log "Ubuntu not found"
    fi
}

cleanup_termux() {
    log "Cleaning Termux files..."

    rm -f "$PREFIX/bin/ubuntu"

    if [ -f "$HOME/.sound" ]; then
        sed -i '/pulseaudio --start/d' "$HOME/.sound"
        sed -i '/module-aaudio-sink/d' "$HOME/.sound"
        sed -i '/module-native-protocol-tcp/d' "$HOME/.sound"
    fi

    ok "Cleanup done"
}

banner
remove_distro
cleanup_termux

echo -e "\n${G}Everything removed successfully${W}"