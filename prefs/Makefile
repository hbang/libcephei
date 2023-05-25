include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = CepheiPrefs

CepheiPrefs_FILES = $(wildcard *.swift) $(wildcard *.m) $(wildcard *.x)
CepheiPrefs_PUBLIC_HEADERS = CepheiPrefs.h HBLinkTableCell.h HBPackageTableCell.h HBPackageNameHeaderCell.h HBStepperTableCell.h HBSupportController.h HBTintedTableCell.h HBTwitterCell.h PSListController+HBTintAdditions.h
CepheiPrefs_FRAMEWORKS = MobileCoreServices
CepheiPrefs_PRIVATE_FRAMEWORKS = MobileIcons Preferences
CepheiPrefs_LIBRARIES = MobileGestalt
CepheiPrefs_WEAK_FRAMEWORKS = SafariServices
CepheiPrefs_CFLAGS = -include Global.h -I.
CepheiPrefs_LDFLAGS = -install_name @rpath/CepheiPrefs.framework/CepheiPrefs
CepheiPrefs_SWIFTFLAGS = -emit-module-interface-path $(THEOS_OBJ_DIR)/CepheiPrefs.swiftinterface -Xcc -fmodule-map-file=$(PWD)/private.modulemap
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

after-CepheiPrefs-all::
	@mkdir -p $(THEOS_OBJ_DIR)/CepheiPrefs.framework/Modules/CepheiPrefs.swiftmodule
	@cp $(THEOS_OBJ_DIR)/$(firstword $(ARCHS))/generated/CepheiPrefs-Swift.h $(THEOS_OBJ_DIR)/CepheiPrefs.framework/Headers
	@cp module.modulemap $(THEOS_OBJ_DIR)/CepheiPrefs.framework/Modules
	@for arch in $(ARCHS); do \
		for file in swiftdoc swiftmodule swiftinterface; do \
			cp $(THEOS_OBJ_DIR)/$$arch/CepheiPrefs.$$file $(THEOS_OBJ_DIR)/CepheiPrefs.framework/Modules/CepheiPrefs.swiftmodule/$$arch.$$file; \
		done; \
	done

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
