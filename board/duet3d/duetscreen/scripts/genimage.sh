#!/usr/bin/env bash

# Use default genimage script
"${BASE_DIR}/../support/scripts/genimage.sh" $@

# Generate NAND update package
echo -n "Generating NAND update package... "
cd "${BINARIES_DIR}"
tar -czf update.tar.gz awboot-boot-spi.bin sun8i-duet3d-duetscreen-linux.dtb optee.bin zImage rootfs.ubi post-update
echo "Done!"
