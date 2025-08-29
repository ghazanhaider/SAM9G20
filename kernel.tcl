NANDFLASH::Init
send_file {NandFlash} "[lindex $argv 3]/ghazans_sam9g20.dtb" 0x100000 0
send_file {NandFlash} "[lindex $argv 3]/zImage" 0x0200000 0
