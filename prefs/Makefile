include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = CepheiPrefs
CepheiPrefs_FILES = $(wildcard *.x) $(wildcard *.m) ../Global.x
CepheiPrefs_PUBLIC_HEADERS = HBAboutListController.h HBAppearanceSettings.h HBDiscreteSliderTableCell.h HBImageTableCell.h HBInitialsLinkTableCell.h HBLinkTableCell.h HBListController.h HBListController+Actions.h HBListItemsController.h HBPackageTableCell.h HBPackageNameHeaderCell.h HBRootListController.h HBSpinnerTableCell.h HBStepperTableCell.h HBSupportController.h HBTintedTableCell.h HBTwitterCell.h PSListController+HBTintAdditions.h
CepheiPrefs_FRAMEWORKS = CoreGraphics MessageUI UIKit
CepheiPrefs_PRIVATE_FRAMEWORKS = Preferences
CepheiPrefs_EXTRA_FRAMEWORKS = Cephei
CepheiPrefs_WEAK_FRAMEWORKS = SafariServices
CepheiPrefs_LIBRARIES = prefs
CepheiPrefs_CFLAGS = -include ../Global.h -fobjc-arc
CepheiPrefs_LDFLAGS = -weak_framework TechSupport

ifeq ($(CEPHEI_EMBEDDED),1)
CepheiPrefs_INSTALL_PATH = @rpath
CepheiPrefs_LOGOSFLAGS = -c generator=internal
else ifeq ($(CEPHEI_SIMULATOR),1)
CepheiPrefs_LOGOSFLAGS = -c generator=internal
else
CepheiPrefs_EXTRA_FRAMEWORKS += CydiaSubstrate
endif

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/framework.mk

after-CepheiPrefs-stage::
ifneq ($(CEPHEI_EMBEDDED),1)
	@# create directories
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/usr/{include,lib} $(THEOS_STAGING_DIR)/Library/PreferenceBundles$(ECHO_END)

	@# libhbangprefs.dylib -> CepheiPrefs.framework
	$(ECHO_NOTHING)ln -s /Library/Frameworks/CepheiPrefs.framework/CepheiPrefs $(THEOS_STAGING_DIR)/usr/lib/libhbangprefs.dylib$(ECHO_END)

	@# libcepheiprefs.dylib -> CepheiPrefs.framework
	$(ECHO_NOTHING)ln -s /Library/Frameworks/CepheiPrefs.framework/CepheiPrefs $(THEOS_STAGING_DIR)/usr/lib/libcepheiprefs.dylib$(ECHO_END)

	@# libhbangprefs.bundle -> Cephei.bundle
	$(ECHO_NOTHING)ln -s Cephei.bundle $(THEOS_STAGING_DIR)/Library/PreferenceBundles/libhbangprefs.bundle$(ECHO_END)

	@# Cephei.bundle -> CepheiPrefs.framework
	$(ECHO_NOTHING)ln -s /Library/Frameworks/CepheiPrefs.framework $(THEOS_STAGING_DIR)/Library/PreferenceBundles/Cephei.bundle$(ECHO_END)

ifeq ($(PACKAGE_BUILDNAME),debug)
	@# install demo entry plist
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)ln -s /Library/PreferenceBundles/Cephei.bundle/entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Cephei.plist$(ECHO_END)
endif
endif
