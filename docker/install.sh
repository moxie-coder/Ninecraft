#!/bin/sh

set -e

# Constants
ID='io.github.mfdgaming.Ninecraft'
NAME='ninecraft'

# Paths
DATA_ROOT="${HOME}/.local/share"
APK_ROOT="$(pwd)"
SRC_ROOT="$(realpath "$(dirname "$0")")"
. "${SRC_ROOT}/common.sh"

# Arguments
ARCH="$1"
validate_arch

# Generate Launcher Script
info 'Creating Launcher...'
LINK="${HOME}/.local/bin/${NAME}"
LAUNCHER="${LINK}-${ARCH}"
cat > "${LAUNCHER}" <<EOF
#!/bin/sh
set -e
exec "${SRC_ROOT}/run.sh" "${ARCH}"
EOF
chmod +x "${LAUNCHER}"
ln --symbolic --force "${LAUNCHER}" "${LINK}"

# Copy Icon
ICON_SRC="${APK_ROOT}/res/drawable/iconx.png"
if [ ! -f "${ICON_SRC}" ]; then
    info 'Skipping Desktop Entry'
    exit 0
fi
info 'Copying Icon...'
ICON_DST="${DATA_ROOT}/icons/hicolor/512x512/apps/${ID}.png"
cp "${ICON_SRC}" "${ICON_DST}"

# Generate Desktop Entry
info 'Creating Desktop Entry...'
APPS="${DATA_ROOT}/applications"
cat > "${APPS}/${ID}.desktop" <<EOF
[Desktop Entry]
Name=Ninecraft
Comment=An MCPE Launcher
Icon=${ICON_DST}
Path=${APK_ROOT}
Exec=${LAUNCHER}
Type=Application
Categories=Game;
Terminal=false
StartupNotify=false
StartupWMClass=ninecraft
EOF
update-desktop-database "${APPS}"
