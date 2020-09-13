include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = CepheiPrefs

# Ensure HBDemoRootListController is the first class linked, to work around an issue with
# Preferences ignoring both `detail` and `NSPrincipalClass` when viewing the demo prefs on old iOS.
CepheiPrefs_FILES = HBDemoRootListController.m $(filter-out HBDemoRootListController.m,$(wildcard *.m) $(wildcard *.x))
CepheiPrefs_PUBLIC_HEADERS = CepheiPrefs.h HBAboutListController.h HBAppearanceSettings.h HBDiscreteSliderTableCell.h HBImageTableCell.h HBInitialsLinkTableCell.h HBLinkTableCell.h HBListController.h HBListController+Actions.h HBListItemsController.h HBPackageTableCell.h HBPackageNameHeaderCell.h HBRootListController.h HBSpinnerTableCell.h HBStepperTableCell.h HBSupportController.h HBTintedTableCell.h HBTwitterCell.h PSListController+HBTintAdditions.h
CepheiPrefs_FRAMEWORKS = MobileCoreServices
CepheiPrefs_PRIVATE_FRAMEWORKS = MobileIcons Preferences
CepheiPrefs_EXTRA_FRAMEWORKS = Cephei
CepheiPrefs_WEAK_FRAMEWORKS = SafariServices
CepheiPrefs_CFLAGS = -include Global.h
CepheiPrefs_INSTALL_PATH = /usr/lib

ifeq ($(CEPHEI_EMBEDDED),1)
CepheiPrefs_INSTALL_PATH = @rpath
CepheiPrefs_LOGOSFLAGS = -c generator=internal
else ifeq ($(CEPHEI_SIMULATOR),1)
CepheiPrefs_LOGOSFLAGS = -c generator=internal
else
CepheiPrefs_EXTRA_FRAMEWORKS += CydiaSubstrate
endif

# As our deployment target is extremely early (iOS 5), some modern symbols need to be weak linked.
# Introduced in iOS 9, but dynamically loaded, so always needs to be weak.
WEAK_CLASS_SYMBOLS = SFSafariViewController
ifneq ($(THEOS_CURRENT_ARCH),arm64e)
	# Introduced before iOS 12, so no need to weak link these on arm64e.
	WEAK_CLASS_SYMBOLS += UIAlertController UIAlertAction
endif
CepheiPrefs_LDFLAGS = $(foreach sym,$(WEAK_CLASS_SYMBOLS),-Xlinker -U -Xlinker _OBJC_CLASS_$$_$(sym))

include $(THEOS_MAKE_PATH)/framework.mk

after-CepheiPrefs-stage::
ifneq ($(CEPHEI_EMBEDDED),1)
	@# create directories
	$(ECHO_NOTHING)mkdir -p \
		$(THEOS_STAGING_DIR)/usr/{include,lib} \
		$(THEOS_STAGING_DIR)/Library/Frameworks \
		$(THEOS_STAGING_DIR)/Library/PreferenceBundles$(ECHO_END)

	@# /usr/lib/CepheiPrefs.framework -> /Library/Frameworks/CepheiPrefs.framework
	$(ECHO_NOTHING)ln -s /usr/lib/CepheiPrefs.framework $(THEOS_STAGING_DIR)/Library/Frameworks/CepheiPrefs.framework$(ECHO_END)

	@# libhbangprefs.dylib -> CepheiPrefs.framework
	$(ECHO_NOTHING)ln -s /usr/lib/CepheiPrefs.framework/CepheiPrefs $(THEOS_STAGING_DIR)/usr/lib/libhbangprefs.dylib$(ECHO_END)

	@# libcepheiprefs.dylib -> CepheiPrefs.framework
	$(ECHO_NOTHING)ln -s /usr/lib/CepheiPrefs.framework/CepheiPrefs $(THEOS_STAGING_DIR)/usr/lib/libcepheiprefs.dylib$(ECHO_END)

	@# libhbangprefs.bundle -> Cephei.bundle
	$(ECHO_NOTHING)ln -s Cephei.bundle $(THEOS_STAGING_DIR)/Library/PreferenceBundles/libhbangprefs.bundle$(ECHO_END)

	@# Cephei.bundle -> CepheiPrefs.framework
	$(ECHO_NOTHING)ln -s /usr/lib/CepheiPrefs.framework $(THEOS_STAGING_DIR)/Library/PreferenceBundles/Cephei.bundle$(ECHO_END)

ifeq ($(PACKAGE_BUILDNAME),debug)
	@# install demo entry plist
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)ln -s /Library/PreferenceBundles/Cephei.bundle/entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Cephei.plist$(ECHO_END)
endif
endif
