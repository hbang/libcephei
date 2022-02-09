# arm64e not needed here
ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TOOL_NAME = hbprefs

hbprefs_FILES = main.m
hbprefs_EXTRA_FRAMEWORKS = Cephei
hbprefs_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/tool.mk
