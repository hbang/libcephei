ifeq ($(CEPHEI_SIMULATOR),1)
	export TARGET = simulator:latest:15.0
else
	export THEOS_PACKAGE_SCHEME = rootless
	export TARGET = iphone:latest:15.0
	export ARCHS = arm64 arm64e
endif

export CEPHEI_EMBEDDED CEPHEI_SIMULATOR

RESPRING ?= 1
INSTALL_TARGET_PROCESSES = Preferences

ifeq ($(RESPRING),1)
	INSTALL_TARGET_PROCESSES += SpringBoard
endif

CEPHEI_SDK_DIR = $(THEOS_OBJ_DIR)/cephei_sdk_$(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

export ADDITIONAL_CFLAGS = \
	-fobjc-arc \
	-Wextra -Wno-unused-parameter \
	-F$(THEOS_OBJ_DIR) \
	-DTHEOS -DTHEOS_LEAN_AND_MEAN \
	-DCEPHEI_VERSION="\"$(THEOS_PACKAGE_BASE_VERSION)\"" \
	-DINSTALL_PREFIX="\"$(THEOS_PACKAGE_INSTALL_PREFIX)\"" \
	-DCEPHEI_EMBEDDED=$(if $(CEPHEI_EMBEDDED),1,0)
export ADDITIONAL_SWIFTFLAGS = -enable-library-evolution
export ADDITIONAL_LDFLAGS = \
	-F$(THEOS_OBJ_DIR) \
	-Xlinker -no_warn_inits

SUBPROJECTS = main ui prefs

ifeq ($(CEPHEI_EMBEDDED),1)
	PACKAGE_BUILDNAME += embedded
else ifneq ($(CEPHEI_SIMULATOR),1)
	SUBPROJECTS += defaults
endif

include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
ifneq ($(CEPHEI_EMBEDDED),1)
	@mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	@cp postinst prerm $(THEOS_STAGING_DIR)/DEBIAN
endif

after-install::
ifneq ($(RESPRING)$(PACKAGE_BUILDNAME),1)
	install.exec "uiopen 'prefs:root=Cephei%20Demo'"
endif

docs: stage
	@$(PRINT_FORMAT_MAKING) "Generating docs"
	@mkdir -p $(THEOS_STAGING_DIR)/usr/lib
	@ln -s $(THEOS_VENDOR_INCLUDE_PATH) $(THEOS_STAGING_DIR)/usr/lib/include
	@jazzy --module-version $(THEOS_PACKAGE_BASE_VERSION)
	@rm -r $(THEOS_STAGING_DIR)/usr
	@rm docs/undocumented.json

sdk: stage
	@$(PRINT_FORMAT_MAKING) "Generating SDK"
	@rm -rf $(CEPHEI_SDK_DIR) $(notdir $(CEPHEI_SDK_DIR)).zip
	@set -e; for i in Cephei CepheiUI CepheiPrefs; do \
		mkdir -p $(CEPHEI_SDK_DIR)/$$i.framework; \
		cp -ra $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Frameworks/$$i.framework/{$$i,Headers,Modules} $(CEPHEI_SDK_DIR)/$$i.framework/; \
		xcrun tapi stubify \
			--filetype=tbd-v4 \
			--delete-input-file \
			$(CEPHEI_SDK_DIR)/$$i.framework/$$i; \
		rm -rf $(THEOS_VENDOR_LIBRARY_PATH)/iphone/rootless/$$i.framework; \
	done
	@rm -r $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Frameworks/*.framework/{Headers,Modules}
	@cp -ra $(CEPHEI_SDK_DIR)/* $(THEOS_VENDOR_LIBRARY_PATH)/iphone/rootless/
	@printf 'This is an SDK for developers wanting to use Cephei.\n\nVersion: %s\n\nFor more information, visit %s.' \
		"$(THEOS_PACKAGE_BASE_VERSION)" \
		"https://hbang.github.io/libcephei/" \
		> $(CEPHEI_SDK_DIR)/README.txt
	@cd $(dir $(CEPHEI_SDK_DIR)); \
		zip -9Xrq "$(THEOS_PROJECT_DIR)/$(notdir $(CEPHEI_SDK_DIR)).zip" $(notdir $(CEPHEI_SDK_DIR))

ifeq ($(FINALPACKAGE),1)
before-package:: sdk
endif

.PHONY: docs sdk
