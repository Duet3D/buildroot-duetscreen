FROM debian:bookworm-slim

# Install essential build tools and dependencies
RUN apt-get update && apt-get install -y \
    bash \
    build-essential \
    wget \
    curl \
    git \
    python3 \
    python3-dev \
    python3-pip \
    libncurses-dev \
    util-linux \
    coreutils \
    patch \
    file \
    perl \
    tar \
    gzip \
    bzip2 \
    xz-utils \
    unzip \
    rsync \
    bc \
    linux-headers-amd64 \
    libssl-dev \
    gcc \
    g++ \
    make \
    cmake \
    autoconf \
    automake \
    libtool \
    bison \
    flex \
    gettext \
    texinfo \
    gawk \
    diffutils \
    which \
    cpio \
    clang-format \
    xxd \
    mkbootimg \
    u-boot-tools \
    dosfstools \
    && rm -rf /var/lib/apt/lists/*

# Set up workspace
WORKDIR /workspaces/buildroot-duetscreen

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# Set environment variables
ENV TERM=xterm-256color
ENV DEBIAN_FRONTEND=noninteractive

# Create build cache directories
RUN mkdir -p /workspaces/buildroot-duetscreen/dl \
    && mkdir -p /workspaces/buildroot-duetscreen/output

# Set user for VS Code
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Switch to non-root user
USER $USERNAME
