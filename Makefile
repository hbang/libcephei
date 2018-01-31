ifeq ($(CEPHEI_SIMULATOR),1)
export TARGET = simulator:latest:5.0
else
export TARGET = iphone:latest:5.0
endif

export ADDITIONAL_CFLAGS = -Wextra -Wno-unused-parameter
export CEPHEI_EMBEDDED CEPHEI_SIMULATOR

INSTALL_TARGET_PROCESSES = Preferences

ifeq ($(RESPRING),1)
INSTALL_TARGET_PROCESSES += SpringBoard
endif

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = Cephei
Cephei_FILES = $(wildcard *.m) $(wildcard *.x) $(wildcard CompactConstraint/*.m)
Cephei_PUBLIC_HEADERS = HBOutputForShellCommand.h HBPreferences.h HBRespringController.h NSDictionary+HBAdditions.h NSString+HBAdditions.h UIColor+HBAdditions.h $(wildcard CompactConstraint/*.h)
Cephei_FRAMEWORKS = CoreGraphics UIKit
Cephei_WEAK_PRIVATE_FRAMEWORKS = FrontBoardServices SpringBoardServices
Cephei_CFLAGS = -include Global.h -fobjc-arc

# link arclite to polyfill some features iOS 5 lacks
armv7_LDFLAGS = -fobjc-arc

SUBPROJECTS = prefs

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
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/usr/{include,lib} $(THEOS_STAGING_DIR)/DEBIAN $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries$(ECHO_END)

	@# libhbangcommon.dylib -> Cephei.framework
	$(ECHO_NOTHING)ln -s /Library/Frameworks/Cephei.framework/Cephei $(THEOS_STAGING_DIR)/usr/lib/libhbangcommon.dylib$(ECHO_END)

	@# libcephei.dylib -> Cephei.framework
	$(ECHO_NOTHING)ln -s /Library/Frameworks/Cephei.framework/Cephei $(THEOS_STAGING_DIR)/usr/lib/libcephei.dylib$(ECHO_END)

	@# postinst -> DEBIAN/post{inst,rm}
	$(ECHO_NOTHING)cp postinst postrm $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)

	@# TODO: this is kind of a bad idea. maybe it should be in its own daemon?
	@# CepheiSpringBoard.dylib -> Cephei.framework
	$(ECHO_NOTHING)ln -s /Library/Frameworks/Cephei.framework/Cephei $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/CepheiSpringBoard.dylib$(ECHO_END)

	@# copy CepheiSpringBoard.plist
	$(ECHO_NOTHING)cp CepheiSpringBoard.plist $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries$(ECHO_END)
endif

after-install::
ifneq ($(RESPRING)$(PACKAGE_BUILDNAME),1)
	install.exec "uiopen 'prefs:root=Cephei%20Demo'"
endif
