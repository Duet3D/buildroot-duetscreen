#!/bin/sh

BOARD_DIR="$(dirname $0)/.."

# Copy board files to BINARY_DIR
cp -rfvd $BOARD_DIR/bin/* $BINARIES_DIR

# Make boot directory
mkdir "$TARGET_DIR/boot"

# Delete unneeded files
rm -f "$TARGET_DIR/etc/init.d/S50dropbear"
rm -f "$TARGET_DIR/lib/dhcpcd/dhcpcd-hooks/50-timesyncd.conf"

# Write most recent git tag to /etc/buildroot_version
GIT_TAG=$(git -C "$(dirname $0)/../.." describe --tags --abbrev=0 2>/dev/null)
echo "${GIT_TAG}" > "$TARGET_DIR/etc/buildroot_version"
