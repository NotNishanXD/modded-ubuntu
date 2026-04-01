#!/bin/bash

# Colors
R="\033[1;31m"
G="\033[1;32m"
Y="\033[1;33m"
C="\033[1;36m"
W="\033[1;37m"

CURR_DIR="$(cd "$(dirname "$0")" && pwd)"
UBUNTU_DIR="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"

banner() {
	clear
	echo -e "${Y}
    _  _ ___  _  _ _  _ ___ _  _    _  _ ____ ___  
${C}    |  | |__] |  | |\ |  |  |  |    |\/| |  | |  \ 
${G}    |__| |__] |__| | \|  |  |__|    |  | |__| |__/ 
${W}
     A modded gui version of ubuntu for Termux
"
}

pkg_install() {
	for pkg in "$@"; do
		if ! command -v "$pkg" >/dev/null 2>&1; then
			echo -e "${G}Installing ${Y}$pkg${W}"
			pkg install -y "$pkg"
		else
			echo -e "${Y}$pkg already installed${W}"
		fi
	done
}

package() {
	banner
	echo -e "${C}Checking required packages...${W}"

	# Storage
	if [ ! -d "$HOME/storage" ]; then
		echo -e "${C}Setting up storage...${W}"
		termux-setup-storage
	fi

	# Update once (not spam)
	pkg update -y && pkg upgrade -y

	pkg_install pulseaudio proot-distro curl
}

distro() {
	echo -e "\n${C}Checking Ubuntu distro...${W}"

	if [ -d "$UBUNTU_DIR" ]; then
		echo -e "${Y}Ubuntu already installed, skipping.${W}"
		return
	fi

	echo -e "${G}Installing Ubuntu...${W}"
	proot-distro install ubuntu || {
		echo -e "${R}Failed to install Ubuntu${W}"
		exit 1
	}

	echo -e "${G}Ubuntu installed successfully${W}"
}

sound() {
	echo -e "\n${C}Fixing sound...${W}"

	SOUND_FILE="$HOME/.sound"

	# Prevent duplicate lines
	grep -qxF "pulseaudio --start --exit-idle-time=-1" "$SOUND_FILE" 2>/dev/null || \
	echo "pulseaudio --start --exit-idle-time=-1" >> "$SOUND_FILE"

	grep -qxF "pacmd load-module module-aaudio-sink" "$SOUND_FILE" 2>/dev/null || \
	echo "pacmd load-module module-aaudio-sink" >> "$SOUND_FILE"

	grep -qxF "pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" "$SOUND_FILE" 2>/dev/null || \
	echo "pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> "$SOUND_FILE"
}

downloader() {
	local path="$1"
	local url="$2"

	echo -e "${C}Downloading $(basename "$path")...${W}"
	curl -L --retry 3 --retry-delay 2 -o "$path" "$url"
}

setup_vnc() {
	echo -e "\n${C}Setting up VNC scripts...${W}"

	for file in vncstart vncstop; do
		if [ -f "$CURR_DIR/distro/$file" ]; then
			cp "$CURR_DIR/distro/$file" "$UBUNTU_DIR/usr/local/bin/$file"
		else
			downloader "$CURR_DIR/$file" "https://raw.githubusercontent.com/modded-ubuntu/modded-ubuntu/master/distro/$file"
			mv "$CURR_DIR/$file" "$UBUNTU_DIR/usr/local/bin/$file"
		fi
		chmod +x "$UBUNTU_DIR/usr/local/bin/$file"
	done
}

permission() {
	banner
	echo -e "${C}Setting up environment...${W}"

	# user.sh
	if [ -f "$CURR_DIR/distro/user.sh" ]; then
		cp "$CURR_DIR/distro/user.sh" "$UBUNTU_DIR/root/user.sh"
	else
		downloader "$CURR_DIR/user.sh" "https://raw.githubusercontent.com/modded-ubuntu/modded-ubuntu/master/distro/user.sh"
		mv "$CURR_DIR/user.sh" "$UBUNTU_DIR/root/user.sh"
	fi

	chmod +x "$UBUNTU_DIR/root/user.sh"

	setup_vnc

	# timezone
	getprop persist.sys.timezone > "$UBUNTU_DIR/etc/timezone"

	# launcher
	echo "proot-distro login ubuntu" > "$PREFIX/bin/ubuntu"
	chmod +x "$PREFIX/bin/ubuntu"

	if [ -f "$PREFIX/bin/ubuntu" ]; then
		banner
		echo -e "${G}Ubuntu CLI installed successfully!${W}

${C}Commands:
${G}ubuntu        ${W}-> Start Ubuntu
${G}bash user.sh ${W}-> Start GUI (inside Ubuntu)

${Y}Restart Termux if anything breaks.${W}
"
	else
		echo -e "${R}Something went wrong creating launcher${W}"
		exit 1
	fi
}

# Run
package
distro
sound
permission