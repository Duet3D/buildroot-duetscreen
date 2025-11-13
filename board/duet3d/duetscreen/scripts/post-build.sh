#!/bin/sh

BOARD_DIR="$(dirname $0)/.."

# Copy board files to BINARY_DIR
cp -rfvd $BOARD_DIR/bin/* $BINARIES_DIR

# Make boot directory
mkdir "$TARGET_DIR/boot"

# Delete unneeded files
rm -f "$TARGET_DIR/etc/init.d/S50dropbear"
rm -f "$TARGET_DIR/lib/dhcpcd/dhcpcd-hooks/50-timesyncd.conf"

