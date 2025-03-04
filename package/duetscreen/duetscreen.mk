################################################################################
#
# DuetScreen
#
################################################################################

DUETSCREEN_VERSION = HEAD
ifdef DUETSCREEN_SRC
DUETSCREEN_SITE = $(DUETSCREEN_SRC)
DUETSCREEN_SITE_METHOD = local
else
DUETSCREEN_SITE = git@github.com:Duet3D/duetscreen.git
DUETSCREEN_SITE_METHOD = git
DUETSCREEN_GIT_SUBMODULES = YES
endif
DUETSCREEN_LICENSE = MIT
DUETSCREEN_LICENSE_FILES = license.txt
DUETSCREEN_DEPENDENCIES = ffmpeg libusb-compat sdl2

DUETSCREEN_PRESET = T113-Debug
DUETSCREEN_CONF_OPTS = --preset $(DUETSCREEN_PRESET)

# Don't use hashes during development
BR_NO_CHECK_HASH_FOR += $(DUETSCREEN_SOURCE)

# cmake-package build does not cd into the src directory unlike the configure step...
define DUETSCREEN_BUILD_CMDS
	cd $(@D); \
	$(TARGET_MAKE_ENV) $(DUETSCREEN_BUILD_ENV) $(BR2_CMAKE) --build --preset $(DUETSCREEN_PRESET) -j$(PARALLEL_JOBS) $(DUETSCREEN_BUILD_OPTS)
endef

define DUETSCREEN_INSTALL_TARGET_CMDS
	install -d -m755 $(TARGET_DIR)/opt/DuetScreen
	install -m644 $(DUETSCREEN_PKGDIR)/config.json $(TARGET_DIR)/etc/duetscreen.json
	install -m755 $(DUETSCREEN_BUILDDIR)/out/build/$(DUETSCREEN_PRESET)/DuetScreen $(TARGET_DIR)/usr/bin/DuetScreen
	install -m755 $(DUETSCREEN_BUILDDIR)/out/build/$(DUETSCREEN_PRESET)/lib/* $(TARGET_DIR)/usr/lib
endef

$(eval $(cmake-package))
