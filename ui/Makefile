include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = CepheiUI
CepheiUI_FILES = $(wildcard *.x) $(wildcard *.m) $(wildcard CompactConstraint/*.m)
CepheiUI_PUBLIC_HEADERS = CepheiUI.h UIColor+HBAdditions.h $(wildcard CompactConstraint/*.h)
CepheiUI_FRAMEWORKS = UIKit WebKit
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

after-CepheiUI-stage::
ifneq ($(CEPHEI_EMBEDDED),1)
ifneq ($(ROOTLESS),1)
	@mkdir -p \
		$(THEOS_STAGING_DIR)/usr/lib \
		$(THEOS_STAGING_DIR)/Library/Frameworks
	@mv $(THEOS_STAGING_DIR)/Library/Frameworks/CepheiUI.framework $(THEOS_STAGING_DIR)/usr/lib
	@ln -s /usr/lib/CepheiUI.framework $(THEOS_STAGING_DIR)/Library/Frameworks/CepheiUI.framework
endif
endif
