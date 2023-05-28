include $(THEOS)/makefiles/common.mk

ifeq ($(ROOT_OBJ_DIR),)
	export ROOT_OBJ_DIR := $(THEOS_OBJ_DIR)
endif

FRAMEWORK_NAME = CepheiPrefs

CepheiPrefs_FILES = $(wildcard *.swift) $(wildcard *.m) $(wildcard *.x)
CepheiPrefs_PUBLIC_HEADERS = CepheiPrefs.h HBAboutListController.h HBLinkTableCell.h HBListController.h HBMastodonTableCell.h HBPackageTableCell.h HBPackageNameHeaderCell.h HBRootListController.h HBStepperTableCell.h HBSupportController.h HBTintedTableCell.h HBTwitterCell.h PSListController+HBTintAdditions.h
CepheiPrefs_FRAMEWORKS = MobileCoreServices
CepheiPrefs_PRIVATE_FRAMEWORKS = MobileIcons Preferences
CepheiPrefs_LIBRARIES = MobileGestalt
CepheiPrefs_WEAK_FRAMEWORKS = SafariServices
CepheiPrefs_CFLAGS = \
	-fmodule-map-file=$(PWD)/module.modulemap \
	-fmodule-map-file=$(PWD)/module.private.modulemap \
	-fmodule-map-file=$(PWD)/objc/module.modulemap \
	-include Global.h \
	-I$(ROOT_OBJ_DIR) \
	-D_CEPHEIPREFS_OBJC_MODULE
CepheiPrefs_LDFLAGS = -install_name @rpath/CepheiPrefs.framework/CepheiPrefs
CepheiPrefs_SWIFTFLAGS = \
	-emit-module-interface-path $(THEOS_OBJ_DIR)/CepheiPrefs.swiftinterface \
	-I. \
	-Iprivate \
	-I$(ROOT_OBJ_DIR)
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
	@sed '/@import CepheiPrefs_ObjC;/d' \
		$(THEOS_OBJ_DIR)/$(firstword $(ARCHS))/generated/CepheiPrefs-Swift.h > $(THEOS_OBJ_DIR)/CepheiPrefs.framework/Headers/CepheiPrefs-Swift.h
	@cp module.modulemap $(THEOS_OBJ_DIR)/CepheiPrefs.framework/Modules
	@for arch in $(ARCHS); do \
		for file in swiftdoc swiftmodule swiftinterface abi.json; do \
			cp $(THEOS_OBJ_DIR)/$$arch/CepheiPrefs.$$file $(THEOS_OBJ_DIR)/CepheiPrefs.framework/Modules/CepheiPrefs.swiftmodule/$$arch-apple-ios.$$file; \
		done; \
	done

after-CepheiPrefs-stage::
ifneq ($(CEPHEI_EMBEDDED),1)
	@mkdir -p $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/PreferenceBundles
	@ln -s $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Frameworks/CepheiPrefs.framework $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/PreferenceBundles/Cephei.bundle

ifeq ($(PACKAGE_BUILDNAME),debug)
	@# Install the demo entry plist
	@mkdir -p $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/PreferenceLoader/Preferences
	@ln -s $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/PreferenceBundles/Cephei.bundle/entry.plist $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/PreferenceLoader/Preferences/Cephei.plist

	@# Install the demo banner
	@cp ../info/logo.jpg $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Frameworks/CepheiPrefs.framework/banner.jpg
endif
endif
