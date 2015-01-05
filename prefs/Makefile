include theos/makefiles/common.mk

BUNDLE_NAME = libcepheiprefs
libcepheiprefs_FILES = $(wildcard *.x) $(wildcard *.m)
libcepheiprefs_INSTALL_PATH = /Library/PreferenceBundles
libcepheiprefs_FRAMEWORKS = CoreGraphics MessageUI UIKit
libcepheiprefs_PRIVATE_FRAMEWORKS = Preferences
libcepheiprefs_CFLAGS = -include HBGlobal.h
libcepheiprefs_LDFLAGS = -weak_framework Twitter
libcepheiprefs_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	ln -s libcepheiprefs.bundle $(THEOS_STAGING_DIR)/Library/PreferenceBundles/libhbangprefs.bundle
	ln -s libcepheiprefs $(THEOS_STAGING_DIR)/Library/PreferenceBundles/libcepheiprefs.bundle/libhbangprefs

	mkdir -p $(THEOS_STAGING_DIR)/usr/lib
	ln -s /Library/PreferenceBundles/libcepheiprefs.bundle/libcepheiprefs $(THEOS_STAGING_DIR)/usr/lib/libcepheiprefs.dylib
	ln -s libcepheiprefs.dylib $(THEOS_STAGING_DIR)/usr/lib/libhbangprefs.dylib

	cp $(THEOS_OBJ_DIR)/libcepheiprefs.bundle/libcepheiprefs $(THEOS)/lib/libcepheiprefs.dylib

ifeq ($(DEBUG),1)
	mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences
	cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/libcepheiprefs.plist
endif
