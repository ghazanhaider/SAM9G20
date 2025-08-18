NANDFLASH::Init
NANDFLASH::EraseAll
send_file {NandFlash} "[lindex $argv 3]/u-boot.bin" 0x040000 0
send_file {NandFlash} "[lindex $argv 3]/zImage" 0x0200000 0
send_file {NandFlash} "[lindex $argv 3]/rootfs.ubi" 0x0800000 0
