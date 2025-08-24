################################################################################
#
# tinycc
#
################################################################################

TINYCC_VERSION = release_0_9_27
TINYCC_SITE = $(call github,TinyCC,tinycc,$(TINYCC_VERSION))
TINYCC_LICENSE = LGPL
TINYCC_LICENSE_FILE = RELICENSING
TINYCC_INSTALL_STAGING = YES
TINYCC_INSTALL_TARGET = YES
TINYCC_CONF_OPTS += --cpu=arm --triplet=arm-linux-gnu

#define TINYCC_BUILD_CMDS
#        $(TARGET_MAKE_ENV) $(MAKE) CROSS_COMPILE="$(TARGET_CROSS)" -C $(@D)
#endef

#define TINYCC_INSTALL_STAGING_CMDS
#        $(TARGET_MAKE_ENV) $(MAKE) \
#                -C $(@D) \
#                PREFIX="/usr" \
#                CROSS_COMPILE="$(TARGET_CROSS)" \
#                DESTDIR="$(STAGING_DIR)" install
#endef
#
#define TINYCC_INSTALL_TARGET_CMDS
#        $(TARGET_MAKE_ENV) $(MAKE) \
#                -C $(@D) \
#                PREFIX="/usr" \
#                CROSS_COMPILE="$(TARGET_CROSS)" \
#                DESTDIR="$(TARGET_DIR)" install
#endef

$(eval $(autotools-package))
