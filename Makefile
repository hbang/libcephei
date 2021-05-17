ifeq ($(CEPHEI_SIMULATOR),1)
export TARGET = simulator:latest:7.0
else
export TARGET = iphone:13.2:7.0
export TARGET_IPHONEOS_DEPLOYMENT_VERSION_armv7 = 5.0
export TARGET_IPHONEOS_DEPLOYMENT_VERSION_arm64 = 7.0
export TARGET_IPHONEOS_DEPLOYMENT_VERSION_arm64e = 12.0
endif

export ADDITIONAL_CFLAGS = -fobjc-arc -Wextra -Wno-unused-parameter -DTHEOS -DTHEOS_LEAN_AND_MEAN -DCEPHEI_VERSION="\"$(THEOS_PACKAGE_BASE_VERSION)\""
export ADDITIONAL_LDFLAGS = -Xlinker -no_warn_inits
export CEPHEI_EMBEDDED CEPHEI_SIMULATOR

RESPRING ?= 1
INSTALL_TARGET_PROCESSES = Preferences

ifeq ($(RESPRING),1)
INSTALL_TARGET_PROCESSES += SpringBoard
endif

CEPHEI_SDK_DIR = $(THEOS_OBJ_DIR)/cephei_sdk_$(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = Cephei
Cephei_FILES = $(wildcard *.m) $(wildcard *.x)
Cephei_PUBLIC_HEADERS = Cephei.h HBOutputForShellCommand.h HBPreferences.h HBRespringController.h NSDictionary+HBAdditions.h NSString+HBAdditions.h
Cephei_INSTALL_PATH = /usr/lib

# link arclite to polyfill some features iOS 5 lacks
armv7_LDFLAGS = -fobjc-arc

SUBPROJECTS = ui prefs

ifeq ($(CEPHEI_EMBEDDED),1)
PACKAGE_BUILDNAME += embedded
ADDITIONAL_CFLAGS += -DCEPHEI_EMBEDDED=1
Cephei_INSTALL_PATH = @rpath
Cephei_LOGOSFLAGS = -c generator=internal
else
ADDITIONAL_CFLAGS += -DCEPHEI_EMBEDDED=0

ifeq ($(CEPHEI_SIMULATOR),1)
Cephei_LOGOSFLAGS = -c generator=internal
else
SUBPROJECTS += defaults
endif
endif

include $(THEOS_MAKE_PATH)/framework.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-Cephei-stage::
ifneq ($(CEPHEI_EMBEDDED),1)
	@# create directories
	$(ECHO_NOTHING)mkdir -p \
		$(THEOS_STAGING_DIR)/DEBIAN $(THEOS_STAGING_DIR)/usr/{include,lib} \
		$(THEOS_STAGING_DIR)/Library/Frameworks \
		$(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries$(ECHO_END)

	@# postinst -> DEBIAN/postinst
	$(ECHO_NOTHING)cp postinst $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)

	@# /usr/lib/Cephei.framework -> /Library/Frameworks/Cephei.framework
	$(ECHO_NOTHING)ln -s /usr/lib/Cephei.framework $(THEOS_STAGING_DIR)/Library/Frameworks/Cephei.framework$(ECHO_END)

	@# libhbangcommon.dylib -> Cephei.framework
	$(ECHO_NOTHING)ln -s /usr/lib/Cephei.framework/Cephei $(THEOS_STAGING_DIR)/usr/lib/libhbangcommon.dylib$(ECHO_END)

	@# libcephei.dylib -> Cephei.framework
	$(ECHO_NOTHING)ln -s /usr/lib/Cephei.framework/Cephei $(THEOS_STAGING_DIR)/usr/lib/libcephei.dylib$(ECHO_END)

	@# TODO: this is kind of a bad idea. maybe it should be in its own daemon?
	@# CepheiSpringBoard.dylib -> Cephei.framework
	$(ECHO_NOTHING)ln -s /usr/lib/Cephei.framework/Cephei $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/CepheiSpringBoard.dylib$(ECHO_END)

	@# copy CepheiSpringBoard.plist
	$(ECHO_NOTHING)cp CepheiSpringBoard.plist $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries$(ECHO_END)
endif

after-install::
ifneq ($(RESPRING)$(PACKAGE_BUILDNAME),1)
#	install.exec "uiopen 'prefs:root=Cephei%20Demo'"
endif

docs: stage
	$(ECHO_NOTHING)ln -s $(THEOS_VENDOR_INCLUDE_PATH) $(THEOS_STAGING_DIR)/usr/lib/include$(ECHO_END)
	$(ECHO_BEGIN)$(PRINT_FORMAT_MAKING) "Generating docs"; jazzy --module-version $(THEOS_PACKAGE_BASE_VERSION)$(ECHO_END)
	$(ECHO_NOTHING)rm $(THEOS_STAGING_DIR)/usr/lib/include$(ECHO_END)
	$(ECHO_NOTHING)rm docs/undocumented.json$(ECHO_END)

sdk: stage
	$(ECHO_BEGIN)$(PRINT_FORMAT_MAKING) "Generating SDK"$(ECHO_END)
	$(ECHO_NOTHING)rm -rf $(CEPHEI_SDK_DIR) $(notdir $(CEPHEI_SDK_DIR)).zip$(ECHO_END)
	$(ECHO_NOTHING)for i in Cephei CepheiUI CepheiPrefs; do \
		mkdir -p $(CEPHEI_SDK_DIR)/$$i.framework; \
		cp -ra $(THEOS_STAGING_DIR)/usr/lib/$$i.framework/{$$i,Headers} $(CEPHEI_SDK_DIR)/$$i.framework/; \
		tbd -p -v1 --ignore-missing-exports \
			--replace-install-name /Library/Frameworks/$$i.framework/$$i \
			$(CEPHEI_SDK_DIR)/$$i.framework/$$i \
			-o $(CEPHEI_SDK_DIR)/$$i.framework/$$i.tbd; \
		rm $(CEPHEI_SDK_DIR)/$$i.framework/$$i; \
		rm -rf $(THEOS_VENDOR_LIBRARY_PATH)/$$i.framework; \
	done$(ECHO_END)
	$(ECHO_NOTHING)rm -r $(THEOS_STAGING_DIR)/usr/lib/*.framework/Headers$(ECHO_END)
	$(ECHO_NOTHING)cp -ra $(CEPHEI_SDK_DIR)/* $(THEOS_VENDOR_LIBRARY_PATH)$(ECHO_END)
	$(ECHO_NOTHING)printf 'This is an SDK for developers wanting to use Cephei.\n\nVersion: %s\n\nFor more information, visit %s.' \
		"$(THEOS_PACKAGE_BASE_VERSION)" \
		"https://hbang.github.io/libcephei/" \
		> $(CEPHEI_SDK_DIR)/README.txt$(ECHO_END)
	$(ECHO_NOTHING)cd $(dir $(CEPHEI_SDK_DIR)); \
		zip -9Xrq "$(THEOS_PROJECT_DIR)/$(notdir $(CEPHEI_SDK_DIR)).zip" $(notdir $(CEPHEI_SDK_DIR))$(ECHO_END)

ifeq ($(FINALPACKAGE),1)
before-package:: sdk
endif

.PHONY: docs sdk
