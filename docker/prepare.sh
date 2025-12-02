#!/bin/sh

set -e
cd "$(dirname "$0")"

# Constants
VERSION='trixie'

# Arguments
TYPE="$1"
ARCH="$2"

# Select Architecture
case "${ARCH}" in
    i686)
        PLATFORM='linux/386'
        CONTAINER_PREFIX='i386/'
        ;;
    arm)
        PLATFORM='linux/arm/v7'
        CONTAINER_PREFIX='arm32v7/'
        ;;
    *)
        echo "Unsupported Architecture: ${ARCH}"
        exit 1
        ;;
esac

# Functions
get() {
    VAR="$1"
    eval "VALUE=\${${VAR}}"
    echo "${VAR}=${VALUE}"
}
gid() {
    NAME="$1"
    getent group "${NAME}" | cut -d: -f3
}

# Build
cd "${TYPE}"
docker build \
    --tag "ninecraft-${TYPE}-${ARCH}" \
    --platform "${PLATFORM}" \
    --build-arg "$(get VERSION)" \
    --build-arg "$(get CONTAINER_PREFIX)" \
    --build-arg "USER_ID=$(id -u)" \
    --build-arg "GROUP_ID=$(id -g)" \
    --build-arg "RENDER_GROUP_ID=$(gid render)" \
    --build-arg "VIDEO_GROUP_ID=$(gid video)" \
    .
