# SAM9G20 board

A simple demo board that breaks out the At91sam9G20, one of the cheapest AT91 available on eBay/aliexpress now.

The board works well with ram/cpu stress testing except:

- SD card pinout is wrong! Doesnt work
- The USB-C connector I used is low quality and the plastic melts before the 63/37 solder.


## Memory Map

At91bootstrap       0x0         0x40000 (Actually burned on the AT45, the NAND's boot section is kept blank)
U-Boot              0x40000     0x80000
U-Boot Env          0xC0000     0x40000 (Actual size in uboot is 0x20000. Backup location 0x180000 but we dont actually burn the backup copy)
DTB                 0x100000    0x80000 (Not used for 2.6.x kernels)
Kernel              0x200000    0x600000
RootFS              0x800000    0xF800000 (0x10000000 - 0x800000)


## Building and running quickstart

- Git clone buildroot and this repository. 
In our case it is `~/buildroot` and `~/SAM9G20`, and user *user1*

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
# echo "Any modifications?"
# make nconfig
# make uboot-nconfig
# make linux-nconfig
# make busybox-nconfig
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
./sam9g20_burn.sh
echo "Press reset once done and enjoy"
```

Reason for this specific buildroot version:
- Trying to use the last 2.6.x kernel, we'll need gcc 4.x latest
- Buildroot 2019.02.11 is the last LTS that provides gcc 4.9.4



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

tcl_lib/at91sam9g20-ek/at91sam9g20-ek.tcl (Line 82):
```
variable extRamDataBusWidth 16
```

Optionally:
applets/legacy/at91lib/boards/at91sam9g20-ek/board.h (Line 487):
```
#define BOARD_SDRAM_SIZE        (32*1024*1024)  // 64 MB
...
#define BOARD_SDRAM_BUSWIDTH    16
```


## AT91Bootstrap3

We use the latest 3.10.4 from git.
The board file is patched with the provided patch (nothing to do)

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

The board file is patched with the provided patch (nothing to do):

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

Tested 4.4.302 and 4.19.x without any patching

The provided dts file covers board specifics


### Older kernels

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

Add this line to full_devices_table.txt:
```
/bin/busybox                            f       755     0       0       -       -       -       -       -
```

Reason:
- All files exist as my local user *user1* and not root, so init/busybox is run as the user that owns it
- The full_devices_table.txt file modifies the owner just before compiling the package
- This way the build doesnt have to run as root, yet the init process works



## TinyCC

I added tinycc to be able to use libiio libgpio etc directly on the device.
In order to use tinycc, we also need to allow musl/kernel headers and libraries from the staged folder:

```
diff --git a/package/musl/musl.mk b/package/musl/musl.mk
index 5db5bbd265..2de1a425d0 100644
--- a/package/musl/musl.mk
+++ b/package/musl/musl.mk
@@ -57,8 +57,8 @@ endef

 define MUSL_INSTALL_TARGET_CMDS
        $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
-               DESTDIR=$(TARGET_DIR) install-libs
-       $(RM) $(addprefix $(TARGET_DIR)/lib/,crt1.o crtn.o crti.o rcrt1.o Scrt1.o)
+               DESTDIR=$(TARGET_DIR) install-libs install-tools install-headers
+#      $(RM) $(addprefix $(TARGET_DIR)/lib/,crt1.o crtn.o crti.o rcrt1.o Scrt1.o)
 endef

 $(eval $(generic-package))
```

.. and Makefile too:
```
diff --git a/Makefile b/Makefile
index 0cbe1076c5..c85e9eb306 100644
--- a/Makefile
+++ b/Makefile
@@ -747,9 +747,9 @@ target-finalize: $(PACKAGES) host-finalize
        ./support/scripts/check-uniq-files -t staging $(BUILD_DIR)/packages-file-list-staging.txt
        ./support/scripts/check-uniq-files -t host $(BUILD_DIR)/packages-file-list-host.txt
        $(foreach hook,$(TARGET_FINALIZE_HOOKS),$($(hook))$(sep))
-       rm -rf $(TARGET_DIR)/usr/include $(TARGET_DIR)/usr/share/aclocal \
-               $(TARGET_DIR)/usr/lib/pkgconfig $(TARGET_DIR)/usr/share/pkgconfig \
-               $(TARGET_DIR)/usr/lib/cmake $(TARGET_DIR)/usr/share/cmake
+       # rm -rf $(TARGET_DIR)/usr/include $(TARGET_DIR)/usr/share/aclocal \
+       #       $(TARGET_DIR)/usr/lib/pkgconfig $(TARGET_DIR)/usr/share/pkgconfig \
+       #       $(TARGET_DIR)/usr/lib/cmake $(TARGET_DIR)/usr/share/cmake
        find $(TARGET_DIR)/usr/{lib,share}/ -name '*.cmake' -print0 | xargs -0 rm -f
        find $(TARGET_DIR)/lib/ $(TARGET_DIR)/usr/lib/ $(TARGET_DIR)/usr/libexec/ \
                \( -name '*.a' -o -name '*.la' \) -print0 | xargs -0 rm -f^[[201~
```


## TODO
lsblk
socket apps
python gpio: universalgpio or
iio or other dht11 controller
