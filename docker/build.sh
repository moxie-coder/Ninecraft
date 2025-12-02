#!/bin/sh

set -e
cd "$(dirname "$0")"

# Arguments
ARCH="$1"

# Prepare Build Environment
./prepare.sh build "${ARCH}"

# Build
ROOT="$(cd ../ && pwd)"
mkdir -p "${ROOT}/build"
docker run \
    --volume "${ROOT}:/data" \
    --user "$(id -u):$(id -g)" \
    --rm \
    "ninecraft-build-${ARCH}" \
    sh -c 'cd /data/build && cmake -DUSE_SYSTEM_DEPENDENCIES=ON .. && cmake --build .'

# Package
cp "${ROOT}/build/ninecraft/ninecraft" run
./prepare.sh run "${ARCH}"
