include theos/makefiles/common.mk

BUNDLE_NAME = libcepheiprefs
libcepheiprefs_FILES = $(wildcard *.x) $(wildcard *.m)
libcepheiprefs_INSTALL_PATH = /Library/PreferenceBundles
libcepheiprefs_FRAMEWORKS = CoreGraphics MessageUI Twitter UIKit
libcepheiprefs_PRIVATE_FRAMEWORKS = Preferences
libcepheiprefs_CFLAGS = -include HBGlobal.h
libcepheiprefs_LIBRARIES = cephei substrate

include $(THEOS_MAKE_PATH)/bundle.mk

after-libcephei-all::
	cp $(THEOS_OBJ_DIR)/libcepheiprefs.bundle/libcepheiprefs $(THEOS)/lib

internal-stage::
	mkdir -p $(THEOS)/include/CepheiPrefs $(THEOS_STAGING_DIR)/usr/include
	rsync -ra *.h $(THEOS_STAGING_DIR)/usr/include/CepheiPrefs --exclude HBGlobal.h
	rsync -ra $(THEOS_STAGING_DIR)/usr/include/CepheiPrefs $(THEOS)/include/CepheiPrefs

	ln -s libcepheiprefs.bundle $(THEOS_STAGING_DIR)/Library/PreferenceBundles/libhbangprefs.bundle
	ln -s libcepheiprefs $(THEOS_STAGING_DIR)/Library/PreferenceBundles/libcepheiprefs.bundle/libhbangprefs

	mkdir -p $(THEOS_STAGING_DIR)/usr/lib
	ln -s /Library/PreferenceBundles/libcepheiprefs.bundle/libcepheiprefs $(THEOS_STAGING_DIR)/usr/lib/libcepheiprefs.dylib
	ln -s libcepheiprefs.dylib $(THEOS_STAGING_DIR)/usr/lib/libhbangprefs.dylib

ifeq ($(DEBUG),1)
	mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences
	mv $(THEOS_STAGING_DIR)/Library/PreferenceBundles/libcepheiprefs.bundle/entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/libcepheiprefs.plist
endif
