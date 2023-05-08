include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = CepheiPrefs

CepheiPrefs_FILES = $(wildcard *.swift) $(wildcard *.m) $(wildcard *.x)
CepheiPrefs_PUBLIC_HEADERS = CepheiPrefs.h HBAboutListController.h HBAppearanceSettings.h HBImageTableCell.h HBLinkTableCell.h HBListController.h HBListController+Actions.h HBPackageTableCell.h HBPackageNameHeaderCell.h HBRootListController.h HBSpinnerTableCell.h HBStepperTableCell.h HBSupportController.h HBTintedTableCell.h HBTwitterCell.h PSListController+HBTintAdditions.h
CepheiPrefs_FRAMEWORKS = MobileCoreServices
CepheiPrefs_PRIVATE_FRAMEWORKS = MobileIcons Preferences
CepheiPrefs_LIBRARIES = MobileGestalt
CepheiPrefs_EXTRA_FRAMEWORKS = Cephei CepheiUI
CepheiPrefs_WEAK_FRAMEWORKS = SafariServices
CepheiPrefs_CFLAGS = -include Global.h -I.
CepheiPrefs_INSTALL_PATH = $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Frameworks

ifeq ($(CEPHEI_EMBEDDED),1)
	CepheiPrefs_INSTALL_PATH = @rpath
	CepheiPrefs_LOGOSFLAGS = -c generator=internal
else ifeq ($(CEPHEI_SIMULATOR),1)
	CepheiPrefs_LOGOSFLAGS = -c generator=internal
else
	CepheiPrefs_EXTRA_FRAMEWORKS += CydiaSubstrate
endif

include $(THEOS_MAKE_PATH)/framework.mk

after-CepheiPrefs-stage::
ifneq ($(CEPHEI_EMBEDDED),1)
	@mkdir -p \
		$(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/PreferenceBundles
	@ln -s $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Frameworks/CepheiPrefs.framework $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/PreferenceBundles/Cephei.bundle

ifeq ($(PACKAGE_BUILDNAME),debug)
	@# Install the demo entry plist
	@mkdir -p $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/PreferenceLoader/Preferences
	@ln -s $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/PreferenceBundles/Cephei.bundle/entry.plist $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/PreferenceLoader/Preferences/Cephei.plist
endif
endif
