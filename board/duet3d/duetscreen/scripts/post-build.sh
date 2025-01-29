#!/bin/sh
BOARD_COMMON_DIR="$(dirname $0)/../../../allwinner-generic/$4"
BOARD_DIR="$(dirname $0)/.."

# Copy Platfrom Files to BINARY_DIR
cp -rfvd $BOARD_COMMON_DIR/bin/*  $BINARIES_DIR

# Copy common file to BINARY_DIR
cp -rfvd $BOARD_COMMON_DIR/../sunxi-generic/bin/* $BINARIES_DIR

# Copy board files to BINARY_DIR
cp -rfvd $BOARD_DIR/bin/* $BINARIES_DIR

# Copy DTB
#cp $BINARIES_DIR/../build/linux-*/arch/arm/boot/dts/$5 $BINARIES_DIR

# Make boot directory
mkdir "$TARGET_DIR/boot"

# Delete unneeded files
rm -f "$TARGET_DIR/etc/init.d/S50dropbear"
rm -f "$TARGET_DIR/lib/dhcpcd/dhcpcd-hooks/50-timesyncd.conf"

# Make boot package
cd $BINARIES_DIR
echo "item=dtb, $5" >> boot_package.cfg
$BINARIES_DIR/dragonsecboot -pack boot_package.cfg

# Make uImage
mkimage -A arm -O linux -T kernel -C none -a 0x40008000 -n "Linux kernel" -d zImage uImage

# Make uboot env
#$BINARIES_DIR/mkenvimage -r -p 0x00 -s 131072 -o env.fex env.cfg

# Make bootable image (with pseudo-ramdisk)
#mkbootimg --kernel zImage --ramdisk ramdisk.img --board sun8iw20p1 --base 0x40200000 --kernel_offset 0x0 --ramdisk_offset 0x01000000 -o boot.img

# Make bootable image (without ramdisk)
mkbootimg --kernel zImage --board sun8iw20p1 --base 0x40000000 -o boot.img

