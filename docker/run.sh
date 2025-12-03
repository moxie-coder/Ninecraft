#!/bin/sh

set -e

# Arguments
ARCH="$1"

# Utility Functions
pass_env() {
    VAR="$1"
    eval "VALUE=\${${VAR}}"
    echo "${VAR}=${VALUE}"
}
pass_volume() {
    VAR="$1"
    eval "VALUE=\${${VAR}}"
    echo "${VALUE}:${VALUE}"
}

# Basic Arguments
set -- docker run \
    --rm \
    --tty

# Access Current Directory
DATA_ROOT='/data'
set -- "$@" \
    --volume "$(pwd):${DATA_ROOT}" \
    --workdir "${DATA_ROOT}"

# HUD
# https://docs.mesa3d.org/envvars.html#gallium-environment-variables
set -- "$@" \
    --env "$(pass_env GALLIUM_HUD)"

# Wayland/X11
if [ "${XDG_SESSION_TYPE}" = 'wayland' ]; then
    set -- "$@" \
        --env 'SDL_VIDEODRIVER=wayland' \
        --volume "$(pass_volume XDG_RUNTIME_DIR)" \
        --env "$(pass_env XDG_RUNTIME_DIR)" \
        --env "$(pass_env WAYLAND_DISPLAY)"
else
    X11_SOCKET='/tmp/.X11-unix'
    set -- "$@" \
        --env "SDL_VIDEODRIVER=x11" \
        --volume "$(pass_volume X11_SOCKET)" \
        --env "$(pass_env DISPLAY)" \
        --volume "$(pass_volume XAUTHORITY)" \
        --env "$(pass_env XAUTHORITY)" \
        --hostname "$(hostname)"
fi

# Audio
PULSE_SOCKET="${XDG_RUNTIME_DIR}/pulse/native"
PULSE_COOKIE="${HOME}/.config/pulse/cookie"
set -- "$@" \
    --env 'SDL_AUDIODRIVER=pulseaudio' \
    --volume "$(pass_volume PULSE_SOCKET)" \
    --volume "$(pass_volume PULSE_COOKIE)" \
    --env "PULSE_SERVER=unix:${PULSE_SOCKET}"

# OpenGL Acceleration
VIRGL='/tmp/.virgl_test'
if fuser "${VIRGL}" > /dev/null 2>&1; then
    set -- "$@" \
        --volume "$(pass_volume VIRGL)" \
        --env 'LIBGL_ALWAYS_SOFTWARE=1' \
        --env 'GALLIUM_DRIVER=virpipe'
else
    set -- "$@" \
        --device /dev/dri
fi

# Docker Image
set -- "$@" \
    "ninecraft-run-${ARCH}"

# Run
exec "$@"
