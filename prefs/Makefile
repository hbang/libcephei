include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = CepheiPrefs
CepheiPrefs_FILES = $(wildcard *.x) $(wildcard *.m)
CepheiPrefs_FRAMEWORKS = CoreGraphics MessageUI Twitter UIKit
CepheiPrefs_PRIVATE_FRAMEWORKS = Preferences
CepheiPrefs_EXTRA_FRAMEWORKS = Cephei TechSupport
CepheiPrefs_CFLAGS = -include HBGlobal.h
CepheiPrefs_LOGOSFLAGS = -c generator=internal

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/framework.mk

after-CepheiPrefs-stage::
	# create directories
	mkdir -p $(THEOS_STAGING_DIR)/usr/{include,lib} $(THEOS_STAGING_DIR)/Library/Frameworks/CepheiPrefs.framework/Headers $(THEOS_STAGING_DIR)/Library/PreferenceBundles

	# copy headers
	rsync -ra *.h $(THEOS_STAGING_DIR)/Library/Frameworks/CepheiPrefs.framework/Headers --exclude HBGlobal.h

	# libhbangprefs.dylib -> libcepheiprefs.dylib
	ln -s libcepheiprefs.dylib $(THEOS_STAGING_DIR)/usr/lib/libhbangprefs.dylib

	# libcepheiprefs.dylib -> CepheiPrefs.framework
	ln -s /Library/Frameworks/CepheiPrefs.framework/CepheiPrefs $(THEOS_STAGING_DIR)/usr/lib/libcepheiprefs.dylib

	# CepheiPrefs -> CepheiPrefs.framework/Headers
	ln -s /Library/Frameworks/CepheiPrefs.framework/Headers $(THEOS_STAGING_DIR)/usr/include/CepheiPrefs

	# libhbangprefs.bundle -> Cephei.bundle
	ln -s Cephei.bundle $(THEOS_STAGING_DIR)/Library/PreferenceBundles/libhbangprefs.bundle

	# Cephei.bundle -> CepheiPrefs.framework
	ln -s /Library/Frameworks/CepheiPrefs.framework $(THEOS_STAGING_DIR)/Library/PreferenceBundles/Cephei.bundle

	# copy to theos lib dir
	rsync -ra $(THEOS_STAGING_DIR)/Library/Frameworks/CepheiPrefs.framework $(THEOS)/lib

ifeq ($(DEBUG),1)
	mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences
	mv $(THEOS_STAGING_DIR)/Library/PreferenceBundles/Cephei.bundle/entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Cephei.plist
endif
