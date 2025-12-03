#!/bin/sh

set -e

# Utility Functions
error() {
    echo "ERROR:" "$@"
    exit 1
}
info() {
    echo "INFO:" "$@"
}
require_file() {
    FILE="$1"
    if [ ! -e "${FILE}" ]; then
        error "Missing File: ${FILE}"
    fi
}

# Arguments
ARCH="$1"
if [ -z "${ARCH}" ]; then
    error 'Missing Architecture'
fi

# Basic Arguments
set -- docker run \
    --rm \
    --tty

# Access Current Directory
DATA_ROOT='/data'
set -- "$@" \
    --volume "$(pwd):${DATA_ROOT}" \
    --workdir "${DATA_ROOT}"

# Networking
pass_port() {
    PORT="$1"
    TYPE="$2"
    echo "${PORT}:${PORT}/${TYPE}"
}
set -- "$@" \
    --publish "$(pass_port 19132 udp)" \
    --publish "$(pass_port 4711 tcp)"

# HUD (https://docs.mesa3d.org/envvars.html#gallium-environment-variables)
set -- "$@" \
    --env GALLIUM_HUD

# Wayland/X11
using() {
    info "Using" "$@"
}
pass_volume() {
    VAR="$1"
    eval "VALUE=\${${VAR}}"
    echo "${VALUE}:${VALUE}"
}
if [ "${XDG_SESSION_TYPE}" = 'wayland' ]; then
    using Wayland
    require_file "${XDG_RUNTIME_DIR}"
    set -- "$@" \
        --env 'SDL_VIDEODRIVER=wayland' \
        --env WAYLAND_DISPLAY \
        --env XDG_RUNTIME_DIR \
        --volume "$(pass_volume XDG_RUNTIME_DIR)"
else
    using X11
    X11_SOCKET='/tmp/.X11-unix'
    require_file "${X11_SOCKET}"
    set -- "$@" \
        --env "SDL_VIDEODRIVER=x11" \
        --volume "$(pass_volume X11_SOCKET)" \
        --env DISPLAY \
        --hostname "$(hostname)"
    if [ -n "${XAUTHORITY}" ]; then
        require_file "${XAUTHORITY}"
        set -- "$@" \
            --env XAUTHORITY \
            --volume "$(pass_volume XAUTHORITY)"
    fi
fi

# Vibration
for DEVICE in /sys/class/input/event*; do
    if [ -e "${DEVICE}" ] && [ -f "${DEVICE}/device/force_feedback/ff_effects_max" ]; then
        NAME="$(basename "${DEVICE}")"
        info "Adding Force-Feedback Device: ${NAME}"
        set -- "$@" \
            --device "/dev/${NAME}"
    fi
done

# Audio
PULSE_SOCKET="${XDG_RUNTIME_DIR}/pulse/native"
if [ -S "${PULSE_SOCKET}" ]; then
    using PulseAudio
    PULSE_COOKIE="${HOME}/.config/pulse/cookie"
    require_file "${PULSE_COOKIE}"
    set -- "$@" \
        --env 'SDL_AUDIODRIVER=pulseaudio' \
        --volume "$(pass_volume PULSE_SOCKET)" \
        --volume "$(pass_volume PULSE_COOKIE)" \
        --env "PULSE_SERVER=unix:${PULSE_SOCKET}"
else
    set -- "$@" \
        --env 'SDL_AUDIODRIVER=dummy'
fi

# OpenGL Acceleration
VIRGL='/tmp/.virgl_test'
if [ -S "${VIRGL}" ] && fuser "${VIRGL}" > /dev/null 2>&1; then
    using VirGL
    set -- "$@" \
        --volume "$(pass_volume VIRGL)" \
        --env 'LIBGL_ALWAYS_SOFTWARE=1' \
        --env 'GALLIUM_DRIVER=virpipe'
else
    using OpenGL
    set -- "$@" \
        --device /dev/dri
fi

# Docker Image
set -- "$@" \
    "ninecraft-run-${ARCH}"

# Run
info 'Running:' "$@"
exec "$@"
