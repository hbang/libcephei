TARGET = iphone:clang:latest:5.0

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = Cephei
Cephei_FILES = $(wildcard *.m) Global.x $(wildcard CompactConstraint/*.m)
Cephei_PUBLIC_HEADERS = HBOutputForShellCommand.h HBPreferences.h UIColor+HBAdditions.h $(wildcard CompactConstraint/*.h)
Cephei_FRAMEWORKS = CoreGraphics UIKit
Cephei_CFLAGS = -include Global.h -fobjc-arc

SUBPROJECTS = prefs containersupport

include $(THEOS_MAKE_PATH)/framework.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-Cephei-stage::
	# create directories
	mkdir -p $(THEOS_STAGING_DIR)/usr/{include,lib} $(THEOS_STAGING_DIR)/DEBIAN

	# libhbangcommon.dylib -> libcephei.dylib
	ln -s libcephei.dylib $(THEOS_STAGING_DIR)/usr/lib/libhbangcommon.dylib

	# libcephei.dylib -> Cephei.framework
	ln -s /Library/Frameworks/Cephei.framework/Cephei $(THEOS_STAGING_DIR)/usr/lib/libcephei.dylib

	# Cephei -> Cephei.framework/Headers
	ln -s /Library/Frameworks/Cephei.framework/Headers $(THEOS_STAGING_DIR)/usr/include/Cephei

	# postinst -> DEBIAN/post{inst,rm}
	cp postinst postrm $(THEOS_STAGING_DIR)/DEBIAN

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences" || true

ifneq ($(DEBUG),0)
	# sbopenurl doesn’t even work on iOS 9…
	# install.exec "sleep 0.2; sbopenurl 'prefs:root=Cephei Demo'"
endif
else
	install.exec spring
endif
