include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = CepheiUI
CepheiUI_FILES = $(wildcard *.swift) $(wildcard *.m)
CepheiUI_PUBLIC_HEADERS = CepheiUI.h
CepheiUI_FRAMEWORKS = UIKit
CepheiUI_CFLAGS = -fapplication-extension
CepheiUI_LDFLAGS = -fapplication-extension -install_name @rpath/CepheiUI.framework/CepheiUI
CepheiUI_SWIFTFLAGS = -emit-module-interface-path $(THEOS_OBJ_DIR)/CepheiUI.swiftinterface
CepheiUI_INSTALL_PATH = $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Frameworks

ifeq ($(CEPHEI_EMBEDDED),1)
	CepheiUI_INSTALL_PATH = @rpath
	CepheiUI_LOGOSFLAGS = -c generator=internal
else ifeq ($(CEPHEI_SIMULATOR),1)
	CepheiUI_LOGOSFLAGS = -c generator=internal
endif

include $(THEOS_MAKE_PATH)/framework.mk

after-CepheiUI-all::
	@mkdir -p $(THEOS_OBJ_DIR)/CepheiUI.framework/Modules/CepheiUI.swiftmodule
	@cp $(THEOS_OBJ_DIR)/$(firstword $(ARCHS))/generated/CepheiUI-Swift.h $(THEOS_OBJ_DIR)/CepheiUI.framework/Headers
	@cp module.modulemap $(THEOS_OBJ_DIR)/CepheiUI.framework/Modules
	@for arch in $(ARCHS); do \
		for file in swiftdoc swiftmodule swiftinterface; do \
			cp $(THEOS_OBJ_DIR)/$$arch/CepheiUI.$$file $(THEOS_OBJ_DIR)/CepheiUI.framework/Modules/CepheiUI.swiftmodule/$$arch.$$file; \
		done; \
	done
