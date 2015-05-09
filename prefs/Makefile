include theos/makefiles/common.mk

BUNDLE_NAME = Cephei
Cephei_INSTALL_PATH = /Library/PreferenceBundles

LIBRARY_NAME = libcepheiprefs
libcepheiprefs_FILES = $(wildcard *.x) $(wildcard *.m)
libcepheiprefs_FRAMEWORKS = CoreGraphics MessageUI Twitter UIKit
libcepheiprefs_PRIVATE_FRAMEWORKS = Preferences
libcepheiprefs_CFLAGS = -include HBGlobal.h
libcepheiprefs_LIBRARIES = cephei MobileGestalt substrate

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/library.mk

after-libcepheiprefs-all::
ifneq ($(DEBUG),1)
	cp $(THEOS_OBJ_DIR)/libcepheiprefs.dylib $(THEOS)/lib/libcepheiprefs.dylib
endif

internal-stage::
	mkdir -p $(THEOS)/include/CepheiPrefs $(THEOS_STAGING_DIR)/usr/include/CepheiPrefs
	rsync -ra *.h $(THEOS_STAGING_DIR)/usr/include/CepheiPrefs --exclude HBGlobal.h
	rsync -ra $(THEOS_STAGING_DIR)/usr/include/CepheiPrefs $(THEOS)/include/CepheiPrefs/

	ln -s Cephei.bundle $(THEOS_STAGING_DIR)/Library/PreferenceBundles/libhbangprefs.bundle
	ln -s Cephei $(THEOS_STAGING_DIR)/Library/PreferenceBundles/Cephei.bundle/libhbangprefs

	mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceBundles/Cephei.bundle
	ln -s /usr/lib/libcepheiprefs.dylib $(THEOS_STAGING_DIR)/Library/PreferenceBundles/Cephei.bundle/Cephei
	ln -s libcepheiprefs.dylib $(THEOS_STAGING_DIR)/usr/lib/libhbangprefs.dylib

ifeq ($(DEBUG),1)
	mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences
	mv $(THEOS_STAGING_DIR)/Library/PreferenceBundles/Cephei.bundle/entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Cephei.plist
endif
