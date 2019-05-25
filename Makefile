THEOS_DEVICE_IP = 192.168.0.146
THEOS_DEVICE_PORT = 22

ifeq ($(SIMULATOR),1)
ARCHS = x86_64
TARGET = simulator:clang:12.1:12.1
else
ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2
endif

# THEOS_PACKAGE_DIR_NAME = debs
# DEBUG = 0
FINAL_PACKAGE=1
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Pliris
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_FRAMEWORKS = UIKit

ifeq ($(SIMULATOR),1)
ADDITIONAL_OBJCFLAGS = -fobjc-arc -DSIMULATOR=1
else
ADDITIONAL_OBJCFLAGS = -fobjc-arc
endif

include $(THEOS_MAKE_PATH)/tweak.mk

## For Image files:
internal-stage::
	mkdir -p "$(THEOS_STAGING_DIR)/Library/Application Support/Pliris.bundle"
	cp Resources/* "$(THEOS_STAGING_DIR)/Library/Application Support/Pliris.bundle"

after-all::
ifeq ($(SIMULATOR),1)
# setup:: clean all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
endif

after-install::
	install.exec "killall -9 SpringBoard"
