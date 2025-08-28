#!/bin/sh
echo "Input argument is: $1"
cd $1/etc/init.d
mv S99iiod K99iiod  2>/dev/null
mv S50nginx K50nginx  2>/dev/null
mv S50crond K50crond  2>/dev/null
mv S40network K40network 2>/dev/null

# Enable debugfs and tracefs auto mount
echo "none            /sys/kernel/debug       debugfs defaults 0 0" >> $1/etc/fstab
echo "none            /sys/kernel/tracing     tracefs rw,relatime,seclabel 0 0" >> $1/etc/fstab

