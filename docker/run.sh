#!/bin/sh

set -e

# Arguments
ARCH="$1"

# Run
get() {
    VAR="$1"
    eval "VALUE=\${${VAR}}"
    echo "${VAR}=${VALUE}"
}
exec docker run \
    --rm \
    --privileged \
    --tty \
    --hostname "$(hostname)" \
    --volume "$(pwd):/data" \
    --workdir '/data' \
    --env "$(get GALLIUM_HUD)" \
    --env "SDL_VIDEODRIVER=wayland,x11" \
    --volume '/tmp/.X11-unix:/tmp/.X11-unix' \
    --env "$(get DISPLAY)" \
    --volume "${XAUTHORITY}:${XAUTHORITY}" \
    --env "$(get XAUTHORITY)" \
    --volume "${XDG_RUNTIME_DIR}:${XDG_RUNTIME_DIR}" \
    --env "$(get XDG_RUNTIME_DIR)" \
    --env "$(get WAYLAND_DISPLAY)" \
    "ninecraft-run-${ARCH}"
