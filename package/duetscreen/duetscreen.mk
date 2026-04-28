################################################################################
#
# DuetScreen
#
################################################################################

DUETSCREEN_VERSION = HEAD

ifdef DUETSCREEN_SRC
DUETSCREEN_SITE = $(DUETSCREEN_SRC)
DUETSCREEN_SITE_METHOD = local
DUETSCREEN_OVERRIDE_SRCDIR_RSYNC_EXCLUSIONS = \
	--include .git \
	--exclude libraries/lvgl/build \
	--exclude libraries/lvgl/tests/build* \
	--exclude out/ \
	--exclude node_modules/
DUETSCREEN_GET_VERSION_CMD = git describe --tags --dirty --always --match="v*"
else
DUETSCREEN_SITE = git@github.com:Duet3D/duetscreen.git
DUETSCREEN_SITE_METHOD = git
DUETSCREEN_GIT_SUBMODULES = YES
DUETSCREEN_GET_VERSION_CMD = GIT_DIR=$(BR2_DL_DIR)/duetscreen/git/.git git describe --tags --dirty --always --match="v*" # This doesn't set the version correctly but this workflow isn't used so it doesn't really matter
endif
DUETSCREEN_LICENSE = MIT
DUETSCREEN_LICENSE_FILES = license.txt
DUETSCREEN_DEPENDENCIES = ffmpeg libpng libusb-compat sdl2 spdlog fmt socat libgpiod wpa_supplicant freetype libxkbcommon

ifndef DUETSCREEN_PRESET
DUETSCREEN_PRESET = T113-Release
endif
DUETSCREEN_CONF_OPTS = --preset $(DUETSCREEN_PRESET)
DUETSCREEN_CONF_OPTS += -DBUILD_SHARED_LIBS=OFF

# Allow additional CMake configure options via environment.
# Example: make DUETSCREEN_EXTRA_CONF_OPTS="-DLOG_LEVEL=DEBUG -DENABLE_FEATURE_X=ON"
ifneq ($(strip $(DUETSCREEN_EXTRA_CONF_OPTS)),)
DUETSCREEN_CONF_OPTS += $(DUETSCREEN_EXTRA_CONF_OPTS)
endif

# Don't use hashes during development
BR_NO_CHECK_HASH_FOR += $(DUETSCREEN_SOURCE)

# cmake-package build does not cd into the src directory unlike the configure step...
define DUETSCREEN_BUILD_CMDS
	cd $(@D); \
	./scripts/update_version.sh "$$($(DUETSCREEN_GET_VERSION_CMD))"
	cd $(@D); \
	$(TARGET_MAKE_ENV) $(DUETSCREEN_BUILD_ENV) $(BR2_CMAKE) --build --preset $(DUETSCREEN_PRESET) -j$(PARALLEL_JOBS) $(DUETSCREEN_BUILD_OPTS)
endef

define DUETSCREEN_INSTALL_TARGET_CMDS
	install -d -m755 $(TARGET_DIR)/opt/DuetScreen
	rm -rf $(TARGET_DIR)/etc/assets
	mkdir -p $(TARGET_DIR)/etc/assets
	rsync -a --chmod=F644,D755 $(DUETSCREEN_BUILDDIR)/assets/ $(TARGET_DIR)/etc/assets/
	install -m755 $(DUETSCREEN_BUILDDIR)/out/build/$(DUETSCREEN_PRESET)/DuetScreen $(TARGET_DIR)/usr/bin/DuetScreen
	# install -m755 $(DUETSCREEN_BUILDDIR)/out/build/$(DUETSCREEN_PRESET)/lib/*.so $(TARGET_DIR)/usr/lib
	# install -m755 $(DUETSCREEN_BUILDDIR)/out/build/$(DUETSCREEN_PRESET)/libraries/lvgl/lib/*.so $(TARGET_DIR)/usr/lib
endef

$(eval $(cmake-package))
