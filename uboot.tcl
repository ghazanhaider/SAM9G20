NANDFLASH::Init
NANDFLASH::EraseAll
send_file {NandFlash} "[lindex $argv 3]/u-boot.bin" 0x040000 0
send_file {NandFlash} "[lindex $argv 3]/uboot-env.bin" 0x180000 0
#send_file {NandFlash} "[lindex $argv 3]/ghazans_sam9g20.dtb" 0x100000 0
#send_file {NandFlash} "[lindex $argv 3]/zImage" 0x0200000 0
