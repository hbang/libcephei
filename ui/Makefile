include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = CepheiUI
CepheiUI_FILES = $(wildcard *.swift) $(wildcard *.m)
CepheiUI_PUBLIC_HEADERS = CepheiUI.h UIColor+HBAdditions.h
CepheiUI_FRAMEWORKS = UIKit
CepheiUI_EXTRA_FRAMEWORKS = Cephei
CepheiUI_CFLAGS = -fapplication-extension
CepheiUI_LDFLAGS = -fapplication-extension
CepheiUI_INSTALL_PATH = $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Frameworks

ifeq ($(CEPHEI_EMBEDDED),1)
	CepheiUI_INSTALL_PATH = @rpath
	CepheiUI_LOGOSFLAGS = -c generator=internal
else ifeq ($(CEPHEI_SIMULATOR),1)
	CepheiUI_LOGOSFLAGS = -c generator=internal
endif

include $(THEOS_MAKE_PATH)/framework.mk
