#!/bin/bash

# This script runs sam-ba 2.x automatically flashing the AT45 Dataflash and NAND
# From the buildroot output images dir, it expects: boot.bin, u-boot.bin, uboot-env.bin, ghazans_sam9g20.dtb, zImage and rootfs.ubi

samba_path="/home/user1/samba/samba2.18"
serial_port="/dev/ttyACM0"

br_images_path="/sam9g20/images"
files=( "boot.bin" "u-boot.bin" "uboot-env.bin" "ghazans_sam9g20.dtb" "zImage" "rootfs.ubi" )

if [ ! -w "$serial_port" ]; then
  echo "Error: Serial port '$serial_port' not found."
  exit 1
fi

if [ ! -d "$br_images_path" ]; then
  echo "Error: Directory doesnt exist: '$br_images_path'"
  exit 1
fi

if [ ! -d "$samba_path" ]; then
  echo "Error: Directory doesnt exist: '$samba_path'"
  exit 1
fi

for file in "${files[@]}"; do
  if [ ! -r "$br_images_path/$file" ]; then
    echo "Error: File not found: $br_images_path/$file"
    exit 1
  fi
done

# Everything is good. Lets flash!

#echo "Flashing At91Bootstrap3 to AT45 Dataflash"
#sudo qemu-amd64 -L /usr/x86_64-linux-gnu/ ${samba_path}/sam-ba_64 /dev/ttyACM0 at91sam9g20-ek samba_at45_write.tcl /sam9g20/images

echo "Writing zImage on NAND without erasing"
sudo qemu-amd64 -L /usr/x86_64-linux-gnu/ ${samba_path}/sam-ba_64 /dev/ttyACM0 at91sam9g20-ek kernel.tcl ${br_images_path}
