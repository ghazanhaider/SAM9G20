################################################################################
#
# tinycc
#
################################################################################

TINYCC_VERSION = release_0_9_27
TINYCC_SITE = $(call github,TinyCC,tinycc,$(TINYCC_VERSION))
TINYCC_LICENSE = LGPL
TINYCC_LICENSE_FILE = RELICENSING
TINYCC_INSTALL_STAGING = NO
TINYCC_INSTALL_TARGET = YES
TINYCC_CONF_OPTS += --cpu=armv5tejl --triplet=arm-linux-gnu --cc=$(TARGET_CROSS)gcc --ar=$(TARGET_CROSS)ar --config-musl --crtprefix=/lib
TINYCC_MAKE_OPTS += arm-libtcc1-usegcc=yes

#TINYCC_CONF_OPTS += --cpu=armv5tejl --triplet=arm-linux-gnu --cc=$(TARGET_CROSS)gcc --ar=$(TARGET_CROSS)ar --config-musl --tcc_sysincludepaths=/usr/include --tcc_libpaths=/lib --crtprefix=/usr/lib


$(eval $(autotools-package))
