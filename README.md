# SAM9G20 board

A simple demo board that breaks out the At91sam9G20, one of the cheapest AT91 available on eBay/aliexpress now.

The board works well with ram/cpu stress testing except:

- SD card pinout is wrong! Doesnt work
- The USB-C connector I used is low quality and the plastic melts before the 63/37 solder.
- When a load is on the USB-A port (ethernet dongle), nand flashing fails randomly. The unclean power might be affecting other things too.


## Memory Map

At91bootstrap       0x0         0x40000 (Actually burned on the AT45, the NAND's boot section is kept blank)
U-Boot              0x40000     0x80000
U-Boot Env          0xC0000     0x40000 (Actual size in uboot is 0x20000. Backup location 0x180000 but we dont actually burn the backup copy)
DTB                 0x100000    0x80000 (Not used for 2.6.x kernels)
Kernel              0x200000    0x600000
RootFS              0x800000    0xF800000 (0x10000000 - 0x800000)


## Quickstart using kernel 2.6.32

- Git clone buildroot and this repository. 
In our case it is `~/buildroot` and `~/SAM9G20`, and user *user1*

Buildroot version 2019.02.11 for older kernels. (2.6.32.71):
```
cd ~
git clone --depth 1 --branch 2019.02.11 git@github.com:buildroot/buildroot.git
git clone git@github.com:ghazanhaider/SAM9G20.git
cd ~/buildroot
patch -p1 < ../SAM9G20/buildroot-2019.02.11.patch
echo "Make an output/build dir. In our case it is /sam9g20"
sudo mkdir /sam9g20
chown user1 /sam9g20
cd /sam9g20
make O=$PWD BR2_EXTERNAL=/home/user1/SAM9G20/br2_external-2019.02.11 -C ~/buildroot list-defconfigs
make O=$PWD BR2_EXTERNAL=/home/user1/SAM9G20/br2_external-2019.02.11 -C ~/buildroot SAM9G20-2.6_defconfig
# Any modifications to do? Look at the next section
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
./2.6_burn.sh
echo "Press reset once done and enjoy"
```


Things that should work
- NAND partitions, and successful boot to UBIFS
- ds1 LED heartbeat
- spidev and i2cdev(using gpio i2c?) devices in /dev, when modules are loaded
- g_serial and getty able to service /dev/ttyGS0
- tcc should compile code against c libraries
- python3 should be able to use libgpiod
- /etc/init.d big services should have been disabled
- debugfs and tracefs filesystems
- latencytop
- Eventually: tcc to compile a kernel module

We cannot use:
- linux-tools-perf (needs uclibc/libelf)
- gdb or gdbserver at either end... compiler errors
- libgpiod



Reason for the older buildroot version:
- Trying to use the last 2.6.x kernel, we'll need gcc 4.9.x latest
- Buildroot 2019.02.11 is the last LTS that provides gcc 4.9.4


## Quickstart using kernel 5.15.190

Buildroot version 2025.02.5 for newer kernels (5.15.190):
```
cd ~
git clone --depth 1 --branch 2025.02.5 git@github.com:buildroot/buildroot.git
git clone git@github.com:ghazanhaider/SAM9G20.git
cd ~/buildroot
patch -p1 < ../SAM9G20/buildroot-2025.02.5.patch
echo "Make an output/build dir. In our case it is /sam9g20"
sudo mkdir /sam9g20
chown user1 /sam9g20
cd /sam9g20
make O=$PWD BR2_EXTERNAL=/home/user1/SAM9G20/br2_external-2025.02.5 -C ~/buildroot list-defconfigs
make O=$PWD BR2_EXTERNAL=/home/user1/SAM9G20/br2_external-2025.02.5 -C ~/buildroot SAM9G20_defconfig
# Any modifications to do? Look at the next section
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

This should work:
- linux-tools-perf  (How to skip perf's docs or install host-python3-asciidoc?)
- tcc+libgpio WORKS
- micropython (does nothing on unix port, no GPIO/SPI etc)
- i2cdev spidev devices
- debugfs tracefs
- strace a tcc


TODO:
test suspent to ram
tcc WORKS except for float/num compilation ?!?
micropython?
gdbserver?
kernel shark?
kgdb?



## Modifications
To make changes:
```
make nconfig
make at91bootstrap3-menuconfig
make uboot-nconfig
make linux-nconfig
make busybox-menuconfig
```

To save tested changes back:
```
make uboot-update-config
make linux-update-config
make busybox-update-config

cp .config ~/SAM9G20/br2_external-2025.02.5/configs/SAM9G20_defconfig3
```



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

(Fix for uboot 2017.11, we do not need this for the newer buildroot set)

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

Both jffs2 and UBI works well for my MT29 Micron NAND without tweaking.

I used jffs2 without issues in the first run. Now both configs use ubifs

Use UBI or JFFS2 image to burn

Add this line to full_devices_table.txt:
```
/bin/busybox                            f       755     0       0       -       -       -       -       -
```

Reason:
- All files exist as my local user *user1* and not root, so init/busybox is run as the user that owns it
- The full_devices_table.txt file modifies the owner just before compiling the package
- This way the build doesnt have to run as root, yet the init process works



## Busybox

To configure:
`make busybox-menuconfig`

I enabled these commands:
- wget+SSL (Just the internal nonchecking SSL to enable downloads)
- netcat nc ipcalc cal nsenter stat iostat pmap



## Working Apps


### TinyCC

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

.. and buildroot/Makefile too:
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


And it works:
```
tcc a.c -o a
```

Or to use some libgpiod example:
```
tcc a.c -o a -lgpiod
```

It failed for math operations like `x = y % 2;`
Math emulation doesnt exist in tinycc and we do not have vfp in our sam9g20


### Libgpiod

Version 1.2.1 installed with this buildroot. The latest for kernel 4.x is 1.6.5

Python bindings are installed too. Just use `import gpiod`


### WiringPi (Newer buildroot has this removed. Avoid)

TODO: libwiringPi check:
```
#include <wiringPi.h> // Include WiringPi library!

int main(void)
{
  // uses BCM numberingof the GPIOs and directly accesses the GPIO registers.
  wiringPiSetupGpio();

  // pin mode ..(INPUT, OUTPUT, PWM_OUTPUT, GPIO_CLOCK)
  // set pin 17 to input
  pinMode(17, INPUT);

  // pull up/down mode (PUD_OFF, PUD_UP, PUD_DOWN) => down
  pullUpDnControl(17, PUD_DOWN);

  // get state of pin 17
  int value = digitalRead(17);

  if (HIGH == value)
  {
    // your code
  }
}
```


### Other useful packages

For a better ps tool, install pstools outside of busybox as well

For the ss network tool, install iproute2

For the *perf* command, install perf under the 'Kernel Tools' section under Kernel instead of packages



## The post_build.sh scrip does these things:

- disable unneeded services in /etc/init.d
- Add two more fstab lines for debugfs and tracefs:
```
none            /sys/kernel/debug       debugfs defaults 0 0
none            /sys/kernel/tracing     tracefs rw,relatime,seclabel 0 0
```

## TODO list

- bpftool
Fix compile errors

- UniversalGPIO
TODO: Need to create package
- reqs of flask and flask-cors added

- iio
Direct and python/c checks

- DHT11 controller/driver
Try with iio driver first (built-in)

- spidev
Try c and python bindings

- linux-tools-perf
Compile fails unless we add NO_LIBBPF=1 in the MAKE FLAGS in buildroot/package/linux-tools/linux-tool-perf.mk.in


## Build log

### Small kernel:

Disabled options:
CONFIG_CMA
CONFIG_CMA_DEBUGFS
block devs in debugfs
CONFIG_SERIO
CONFIG_SERIO_SERPORT
CONFIG_LEGACY_PTYS
CONFIG_LDISC_AUTOLOAD
CONFIG_RANDOM_TRUST_BOOTLOADER
CONFIG_USB_MON
CONFIG_AUXDISPLAY
CONFIG_CPU_SW_DOMAIN_PAN

enabled:
CONFIG_ATMEL_TCLIB=y
CONFIG_PWM_ATMEL_TCB=m
CONFIG_ATMEL_CLOCKSOURCE_TCB is enabled
- selects ATMEL_TCB_CLKSRC=y

Result: Memory: 26532K/32768K available (3819K kernel code, 375K rwdata, 1080K rodata, 304K init, 95K bss, 6236K reserved, 0K cma-reserved)


### Complete kernel:

disable: CONFIG_ATMEL_TCLIB
- CONFIG_PWM_ATMEL_TCB=n 
enabled:
CONFIG_PREEMPT
CONFIG_PROFILING
CONFIG_RELAY
CONFIG_BPF_SYSCALL
CONFIG_UACCESS_WITH_MEMCPY
CONFIG_JUMP_LABEL
CONFIG_STACKPROTECTOR
CONFIG_STACKPROTECTOR_STRONG
CONFIG_STRICT_KERNEL_RWX
CONFIG_MQ_IOSCHED_KYBER
CONFIG_IOSCHED_BFQ
CONFIG_CMA
CONFIG_CMA_DEBUGFS


Result: Memory: 23668K/32768K available (5120K kernel code, 396K rwdata, 1144K rodata, 1024K init, 99K bss, 9100K reserved, 0K cma-reserved)


### Similar 5.15 kernel:

Result: Memory: 23584K/32768K available (5120K kernel code, 469K rwdata, 1196K rodata, 1024K init, 102K bss, 9184K reserved, 0K cma-reserved)


### And 2.6.32:

Memory: 29120KB available (2888K code, 329K data, 100K init, 0K highmem)
