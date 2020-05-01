# arm64e not needed here
ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TOOL_NAME = defaults

defaults_FILES = main.m
defaults_EXTRA_FRAMEWORKS = Cephei
defaults_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/tool.mk
