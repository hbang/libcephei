TARGET = iphone:clang:latest:5.0

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = Cephei
Cephei_FILES = $(wildcard *.m) Global.x $(wildcard CompactConstraint/*.m)
Cephei_PUBLIC_HEADERS = HBOutputForShellCommand.h HBPreferences.h UIColor+HBAdditions.h $(wildcard CompactConstraint/*.h)
Cephei_FRAMEWORKS = CoreGraphics UIKit
Cephei_WEAK_PRIVATE_FRAMEWORKS = FrontBoardServices SpringBoardServices
Cephei_EXTRA_FRAMEWORKS = CydiaSubstrate
Cephei_CFLAGS = -include Global.h -fobjc-arc

SUBPROJECTS = prefs containersupport

include $(THEOS_MAKE_PATH)/framework.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-Cephei-stage::
	@# create directories
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/usr/{include,lib} $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)

	@# libhbangcommon.dylib -> libcephei.dylib
	$(ECHO_NOTHING)ln -s libcephei.dylib $(THEOS_STAGING_DIR)/usr/lib/libhbangcommon.dylib$(ECHO_END)

	@# libcephei.dylib -> Cephei.framework
	$(ECHO_NOTHING)ln -s /Library/Frameworks/Cephei.framework/Cephei $(THEOS_STAGING_DIR)/usr/lib/libcephei.dylib$(ECHO_END)

	@# Cephei -> Cephei.framework/Headers
	$(ECHO_NOTHING)ln -s /Library/Frameworks/Cephei.framework/Headers $(THEOS_STAGING_DIR)/usr/include/Cephei$(ECHO_END)

	@# postinst -> DEBIAN/post{inst,rm}
	$(ECHO_NOTHING)cp postinst postrm $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences" || true

ifneq ($(DEBUG),0)
	install.exec "uiopen prefs:"
endif
else
	install.exec spring
endif
