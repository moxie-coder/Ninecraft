# syntax=docker/dockerfile:1
# check=error=true;skip=InvalidDefaultArgInFrom

# Base Container
ARG CONTAINER_PREFIX
ARG VERSION
FROM "${CONTAINER_PREFIX}debian:${VERSION}"

# Install Dependencies
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        zlib1g \
        libsdl2-2.0-0 \
        libglvnd0 \
        libgl1 libgl1-mesa-dri \
        libegl1 libegl-mesa0 \
        libglx-mesa0 \
        libdecor-0-0 libdecor-0-plugin-1-cairo \
        zenity && \
    rm -rf /var/lib/apt/lists/*

# Setup User
ARG USER_ID
ARG GROUP_ID
ARG RENDER_GROUP_ID
ARG VIDEO_GROUP_ID
RUN \
    groupadd --non-unique --gid "${GROUP_ID}" main && \
    groupadd --non-unique --gid "${RENDER_GROUP_ID}" one && \
    groupadd --non-unique --gid "${VIDEO_GROUP_ID}" two && \
    useradd --non-unique --create-home --uid "${USER_ID}" --gid "${GROUP_ID}" --groups one,two user
USER user

# Add App
COPY ninecraft /
ENTRYPOINT ["/ninecraft"]
