include $(THEOS)/makefiles/common.mk

TOOL_NAME = hbprefsd

hbprefsd_FILES = $(wildcard *.m) ../HBPreferences.m ../HBPreferencesCore.m
hbprefsd_INSTALL_PATH = /usr/libexec
hbprefsd_CFLAGS = -DCEPHEI_HBPREFSD -I.. -include ../Global.h -fobjc-arc
hbprefsd_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/tool.mk

after-hbprefsd-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)
	$(ECHO_NOTHING)cp ws.hbang.common.hbprefsd.plist $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)
