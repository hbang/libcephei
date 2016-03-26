include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = CepheiPrefs
CepheiPrefs_FILES = $(wildcard *.x) $(wildcard *.m) ../Global.x
CepheiPrefs_PUBLIC_HEADERS = HBAboutListController.h HBAppearanceSettings.h HBPackageNameHeaderCell.h HBLinkTableCell.h HBInitialsLinkTableCell.h HBListController.h HBListItemsController.h HBDiscreteSliderTableCell.h HBImageTableCell.h HBRootListController.h HBSpinnerTableCell.h HBStepperTableCell.h HBSupportController.h HBTintedTableCell.h HBTwitterCell.h PSListController+HBTintAdditions.h
CepheiPrefs_FRAMEWORKS = CoreGraphics MessageUI Twitter UIKit
CepheiPrefs_PRIVATE_FRAMEWORKS = Preferences
CepheiPrefs_EXTRA_FRAMEWORKS = Cephei TechSupport
CepheiPrefs_LIBRARIES = prefs substrate
CepheiPrefs_CFLAGS = -include ../Global.h -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/framework.mk

after-CepheiPrefs-all::
	# create directories
	mkdir -p $(THEOS_OBJ_DIR)/CepheiPrefs.framework/Headers

	# copy headers
	rsync -ra $(CepheiPrefs_PUBLIC_HEADERS) $(THEOS_OBJ_DIR)/CepheiPrefs.framework/Headers

	# copy to theos lib dir
	rsync -ra $(THEOS_OBJ_DIR)/CepheiPrefs.framework $(THEOS)/lib

after-CepheiPrefs-stage::
	# create directories
	mkdir -p $(THEOS_STAGING_DIR)/usr/{include,lib} $(THEOS_STAGING_DIR)/Library/PreferenceBundles

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

ifeq ($(DEBUG),1)
	# install demo entry plist
	mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences
	mv $(THEOS_STAGING_DIR)/Library/PreferenceBundles/Cephei.bundle/entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Cephei.plist
endif
