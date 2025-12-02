#!/bin/sh

set -e

# Constants
ID='io.github.mfdgaming.Ninecraft'

# Arguments
ARCH="$1"

# Paths
APK_ROOT="$(pwd)"
SRC_ROOT="$(dirname "$0")"
DATA_ROOT="${HOME}/.local/share"

# Copy Icon
ICON="${DATA_ROOT}/icons/hicolor/512x512/apps/${ID}.png"
cp "${APK_ROOT}/res/drawable/iconx.png" "${ICON}"

# Generate Desktop Entry
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
