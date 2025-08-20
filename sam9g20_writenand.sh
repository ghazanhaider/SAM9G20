#!/bin/sh

# This script runs sam-ba 2.x automatically erasing NAND and reimaging it.
# From the buildroot output images dir, it expects: boot.bin, u-boot.bin, uboot-env.bin, ghazans_sam9g20.dtb, zImage and rootfs.ubi

samba_path=/home/user1/samba/samba2.18
br_images_path=/sam9g20/images
serial_port=/dev/ttyACM0

echo "Reimaging NAND"
echo " - Sam-ba 2.x is at: ${samba_path}"
echo " - Buildroot build dir is at: /sam9g20"
sudo qemu-amd64 -L /usr/x86_64-linux-gnu/ ${samba_path}/sam-ba_64 /dev/ttyACM0 at91sam9g20-ek samba_nand_write.tcl ${br_images_path}
