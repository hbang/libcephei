# arm64e not needed here
ARCHS := $(filter-out arm64e,$(ARCHS))

include $(THEOS)/makefiles/common.mk

TOOL_NAME = hbprefs

hbprefs_FILES = main.m
hbprefs_EXTRA_FRAMEWORKS = Cephei
hbprefs_CODESIGN_FLAGS = -Sentitlements.plist
hbprefs_INSTALL_PATH = $(THEOS_PACKAGE_INSTALL_PREFIX)/usr/bin

include $(THEOS_MAKE_PATH)/tool.mk
