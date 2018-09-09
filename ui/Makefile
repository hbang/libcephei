include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = CepheiUI
CepheiUI_FILES = $(wildcard *.x) $(wildcard *.m) $(wildcard CompactConstraint/*.m)
CepheiUI_PUBLIC_HEADERS = CepheiUI.h UIColor+HBAdditions.h $(wildcard CompactConstraint/*.h)
CepheiUI_FRAMEWORKS = UIKit WebKit
CepheiUI_EXTRA_FRAMEWORKS = Cephei
CepheiUI_CFLAGS = -include ../Global.h -fobjc-arc
CepheiUI_INSTALL_PATH = /usr/lib

ifeq ($(CEPHEI_EMBEDDED),1)
CepheiUI_INSTALL_PATH = @rpath
CepheiUI_LOGOSFLAGS = -c generator=internal
else ifeq ($(CEPHEI_SIMULATOR),1)
CepheiUI_LOGOSFLAGS = -c generator=internal
else
endif

include $(THEOS_MAKE_PATH)/framework.mk

after-CepheiUI-stage::
ifneq ($(CEPHEI_EMBEDDED),1)
	@# create directories
	$(ECHO_NOTHING)mkdir -p \
		$(THEOS_STAGING_DIR)/Library/Frameworks$(ECHO_END)

	@# /usr/lib/CepheiUI.framework -> /Library/Frameworks/CepheiUI.framework
	$(ECHO_NOTHING)ln -s /usr/lib/CepheiUI.framework $(THEOS_STAGING_DIR)/Library/Frameworks/CepheiUI.framework$(ECHO_END)
endif
