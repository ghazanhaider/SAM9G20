# SAM9G20 board

A simple demo board that breaks out the At91sam9G20, one of the cheapest AT91 available on eBay/aliexpress now.

The board works well with ram/cpu stress testing except:

- SD card pinout is wrong! Doesnt work
- The USB-C connector I used is low quality and the plastic melts before the 63/37 solder.


## Memory Map

At91bootstrap       0x0         0x40000 (Actually burned on the AT45, the NAND's boot section is kept blank)
U-Boot              0x40000     0x80000
U-Boot Env          0xC0000     0x40000 (We did not use this, just updated built-in env)
DTB                 0x100000    0x80000 (Did not add the modified DTB either, trying out 2.6 kernel)
Kernel              0x200000    0x60000
RootFS              0x800000    -


## Building and running cheatsheet

- Git clone buildroot and this repository. 
In our case it is `~/buildroot` and `~/SAM9G20`
Trying to use the last 2.6.x kernel, we'll need gcc 4.x latest
Buildroot 2019.02.11 is the last LTS that provides gcc 4.9.4
```
cd ~
git clone --depth 1 --branch 2019.02.11 git@github.com:buildroot/buildroot.git
git clone git@github.com:ghazanhaider/SAM9G20.git
echo "Make an output/build dir. In our case it is /sam9g20"
sudo mkdir /sam9g20
chown user1 /sam9g20
cd /sam9g20
make O=$PWD BR_EXTERNAL=/home/user1/SAM9G20/br2_external -C ~/buildroot list-defconfigs
make O=$PWD BR_EXTERNAL=/home/user1/SAM9G20/br2_external -C ~/buildroot SAM9G20_defconfig
echo "Any modifications?"
make nconfig
make uboot-nconfig
make linux-nconfig
make busybox-nconfig
echo "Make all but in steps"
make toolchain
make at91bootstrap3
make uboot
make linux
make all
echo "Burn (Need to have sam-ba2.18 setup as per next stage)"
echo "Connect the board to USB, DBGU pins to a terminal"
echo "Keep BOOT pressed while pressing RESET and let go"
echo "The DBGU console should show Romboot followed by a >"
cd ~/SAM9G20
sam9g20_writenand.sh
echo "Press reset once done and enjoy"
```

TODO for above:
- fix at91bootstrap and uboot version
- Fix device list to add /bin/busybox


## SAM-BA 2.18 Install and run

This is the last verison that supports 'legacy' boards like the 9G20.

It runs on Windows 10 well, but the Linux version is tricky. Much more so on a MacOS ARM system.

To run it through qemu user mode, I had to install and setup xorg on Ubuntu 24.04 (VMware Player on MacOS)

These packages were needed to be installed by force (not using --add-architecture):
```
libbrotli1_1.1.0-2build2_amd64.deb
libbz2-1.0_1.0.8-5.1build0.1_amd64.deb
libexpat1_2.6.1-2ubuntu0.3_amd64.deb
libfontconfig1_2.15.0-1.1ubuntu2_amd64.deb
libfreetype6_2.13.2+dfsg-1build3_amd64.deb
libpng16-16t64_1.6.43-5build1_amd64.deb
libxext6_1.3.3-1_amd64.deb
libxext6_1.3.4-1build2_amd64.deb
libxft2_2.3.6-1build1_amd64.deb
libxrender1_0.9.10-1.1build1_amd64.deb
libxss1_1.2.3-1_amd64.deb
multiarch-support_2.27-3ubuntu1.6_amd64.deb
```

Install like so: `sudo dpkg --ignore-depends=multiarch-support --force-architecture -i *.deb`
They make apt very unhappy and can be removed like this:
```
sudo dpkg --force-architecture -r libbrotli1:amd64 libbz2-1.0:amd64 libexpat1:amd64 libfontconfig1:amd64 libfreetype6:amd64 libpng16-16t64:amd64 libxext6:amd64 libxext6:amd64 libxft2:amd64 libxrender1:amd64 libxss1:amd64 multiarch-support:amd64
```


Once X is running, the DISPLAY environment variable is set and the Atmel CDC device is passed through into the VM:
```
qemu-amd64 -L /usr/x86_64-linux-gnu/ /home/user1/samba/samba2.17/sam-ba_64
```


## SAM-BA Fixes
SAM-BA's board file for at91sam9g20-ek must be modified because it expects an 8-bit NAND and 32-bit SDRAM but we have 16-bit of both.

Line 82:
```
variable extRamDataBusWidth 16
```


## AT91Bootstrap3

Do not use the 3.8.x version which has a bug.
Use the latest 3.10.4 from git.

Modify:
build/at91bootstrap3-at91bootstrap-3.x/board/at91sam9g20ek/at91sam9g20ek.c
```
Change AT91C_SDRAMC_DBW_32_BITS to AT91C_SDRAMC_DBW_16_BITS
Change AT91C_SMC_DBW_WIDTH_BITS_8 to AT91C_SMC_DBW_WIDTH_BITS_16
```

SDRAM settings that we're keeping. Just comparing datasheet numbers, nothing to do here.
The Hynix ram I used matches these on the dot, no performance to be gained by tweaking these without instability.
```
- CLK at 133MHz is 7.52ns
AT91C_SDRAMC_TWR_3 ? (default 2)
AT91C_SDRAMC_TRC_9 ? (default 7) (min 20ns from datasheet, > 3)
AT91C_SDRAMC_TRP_3 default 3 (min 20ns from datasheet, > 3)
AT91C_SDRAMC_TRCD_3 ? (default 2) (min 20ns from datasheet > 3)
AT91C_SDRAMC_TRAS_6 ? (default 5) (min 42ns from datasheet, > 6)
AT91C_SDRAMC_TXSR_10 ? (default 8 / 75.2ns) (nothing in Hynix datasheet)
```


## U-Boot
To set default env, modify these vars in include/configs/at91sam9g20ek.h:
```
#define CONFIG_SYS_NAND_DBW_16
#define CONFIG_SYS_LOAD_ADDR                    0x21000000      /* load address */
#define CONFIG_SYS_MEMTEST_END                  0x21e00000
#define CONFIG_BOOTCOMMAND      "nand read 0x21000000 0x200000 0x300000; bootz 0x21000000"
#define CONFIG_EXTRA_ENV_SETTINGS "stdin=serial@fffff200\0stdout=serial@fffff200\0stderr=serial@fffff200\0baudrate=115200\0"
```
Reason: The EK board has 64MB ram but we have 32MB so we cannot go over 0x22000000


## Linux kernel
Trying to stay old with 2.6.x, I used 2.6.39.4 and 2.6.32.71
(The provided devicetree works tested with kernel 4.4.302)

- Runs into this bug for 2.6.39.x:
https://bugs.linaro.org/show_bug.cgi?id=928#c7
Workaround to add `-fno-builtin-memset` in Makefile line 638:
```
KBUILD_CFLAGS += -fno-builtin-memset
KBUILD_CPPFLAGS += -fno-builtin-memset
```

There are probably better ways like adding KCFLAG env variable somewhere. But this works.

I'll test this in the future instead on the command line:
`KCFLAGS=-fno-builtin-memset make linux`

Make sure 16-bit NAND is compiled

- Fix MMC code to add slot[0] where only slot[1] is added:
In /source/arch/arm/mach-at91/board-sam9g20ek.c:
 Delete lines 239 and 242 to remove the 2mmc condition.(Didnt have to for 2.6.32)

- Change the LED struct to only have ds1 using PB9 pin:
```
static struct gpio_led ek_leds[] = {
        {       /* "power" led, yellow */
                .name                   = "ds1",
                .gpio                   = AT91_PIN_PB9,
                .default_trigger        = "heartbeat",
        }
};
```

- Under ek_board_init(), comment the last 3 functions because we do not have buttons or sound:
```
//      ek_add_device_buttons();
        /* PCK0 provides MCLK to the WM8731 */
//      at91_set_B_periph(AT91_PIN_PC1, 0);
        /* SSC (for WM8731) */
//      at91_add_device_ssc(AT91SAM9260_ID_SSC, ATMEL_SSC_TX);
```


## Filesystem

Both jffs2 and UBI works well for my MT29 Micron NAND without tweaking (except for 16bit wide settings above)

Use UBI or JFFS2 image to burn

Somehow all files exist as my local user and not root, so init is run as my user which in the embedded system does not exist.

So before creating the filesystem, run `chown -h root:root /sam9g20/target/bin/busybox`. Do this after any busybox config change because it installs it as my local user and not root.

The boot will then work as expected.


## TODO

Try out the latest kernel/buildroot
