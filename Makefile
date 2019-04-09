ifeq ($(CEPHEI_SIMULATOR),1)
export TARGET = simulator:latest:7.0
else
export TARGET = iphone:12.2:7.0
export TARGET_IPHONEOS_DEPLOYMENT_VERSION_armv7 = 5.0
endif

export ADDITIONAL_CFLAGS = -Wextra -Wno-unused-parameter -DTHEOS
export ADDITIONAL_LDFLAGS = -Xlinker -no_warn_inits
export ARCHS = armv7 arm64
export CEPHEI_EMBEDDED CEPHEI_SIMULATOR

RESPRING ?= 1
INSTALL_TARGET_PROCESSES = Preferences

ifeq ($(RESPRING),1)
INSTALL_TARGET_PROCESSES += SpringBoard
endif

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = Cephei
Cephei_FILES = $(wildcard *.m) $(wildcard *.x)
Cephei_PUBLIC_HEADERS = Cephei.h HBOutputForShellCommand.h HBPreferences.h HBRespringController.h NSDictionary+HBAdditions.h NSString+HBAdditions.h
Cephei_CFLAGS = -include Global.h -fobjc-arc
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
Cephei_WEAK_LIBRARIES = $(THEOS_VENDOR_LIBRARY_PATH)/librocketbootstrap.dylib

ifeq ($(CEPHEI_SIMULATOR),1)
Cephei_LOGOSFLAGS = -c generator=internal
else
SUBPROJECTS += defaults containersupport
Cephei_EXTRA_FRAMEWORKS += CydiaSubstrate
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

	@# postinst -> DEBIAN/post{inst,rm}
	$(ECHO_NOTHING)cp postinst postrm $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)

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

ifeq ($(FINALPACKAGE),1)
before-package:: docs
endif
