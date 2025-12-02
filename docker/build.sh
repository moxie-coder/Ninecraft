#!/bin/sh

set -e
cd "$(dirname "$0")"

# Arguments
ARCH="$1"

# Prepare Build Environment
./prepare.sh build "${ARCH}"

# Build
ROOT="$(cd ../ && pwd)"
BUILD="build-docker-${ARCH}"
mkdir -p "${ROOT}/${BUILD}"
docker run \
    --volume "${ROOT}:/data" \
    --user "$(id -u):$(id -g)" \
    --rm \
    --workdir "/data/${BUILD}" \
    "ninecraft-build-${ARCH}" \
    sh -c 'cmake -DUSE_SYSTEM_DEPENDENCIES=ON .. && cmake --build .'

# Package
cp "${ROOT}/${BUILD}/ninecraft/ninecraft" run
./prepare.sh run "${ARCH}"
