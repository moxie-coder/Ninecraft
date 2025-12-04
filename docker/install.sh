#!/bin/sh

set -e

# Constants
ID='io.github.mfdgaming.Ninecraft'

# Paths
DATA_ROOT="${HOME}/.local/share"
APK_ROOT="$(pwd)"
SRC_ROOT="$(dirname "$0")"
. "${SRC_ROOT}/common.sh"

# Arguments
ARCH="$1"
validate_arch

# Copy Icon
info 'Copying Icon...'
ICON="${DATA_ROOT}/icons/hicolor/512x512/apps/${ID}.png"
cp "${APK_ROOT}/res/drawable/iconx.png" "${ICON}"

# Generate Desktop Entry
info 'Creating Desktop Entry...'
APPS="${DATA_ROOT}/applications"
cat > "${APPS}/${ID}.desktop" <<EOF
[Desktop Entry]
Name=Ninecraft
Comment=An MCPE Launcher
Icon=${ICON}
Path=${APK_ROOT}
Exec=${SRC_ROOT}/run.sh ${ARCH}
Type=Application
Categories=Game;
Terminal=false
StartupNotify=false
StartupWMClass=ninecraft
EOF
update-desktop-database "${APPS}"
