include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = Cephei

Cephei_FILES = $(wildcard *.swift) $(wildcard *.m) $(wildcard *.x)
Cephei_PUBLIC_HEADERS = Cephei.h HBOutputForShellCommand.h HBPreferences.h HBRespringController.h
Cephei_CFLAGS = \
	-fapplication-extension \
	-fmodule-map-file=module.modulemap \
	-include Global.h \
	-DROCKETBOOTSTRAP_LOAD_DYNAMIC
Cephei_LDFLAGS = -fapplication-extension -install_name @rpath/Cephei.framework/Cephei
Cephei_SWIFTFLAGS = -emit-module-interface-path $(THEOS_OBJ_DIR)/Cephei.swiftinterface
Cephei_INSTALL_PATH = $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Frameworks

ifeq ($(CEPHEI_EMBEDDED),1)
	Cephei_INSTALL_PATH = @rpath
	Cephei_LOGOSFLAGS = -c generator=internal
endif

include $(THEOS_MAKE_PATH)/framework.mk

after-Cephei-all::
	@mkdir -p $(THEOS_OBJ_DIR)/Cephei.framework/Modules/Cephei.swiftmodule
	@cp $(THEOS_OBJ_DIR)/$(firstword $(ARCHS))/generated-headers/Cephei-Swift.h $(THEOS_OBJ_DIR)/Cephei.framework/Headers
	@cp module.modulemap $(THEOS_OBJ_DIR)/Cephei.framework/Modules
	@for arch in $(ARCHS); do \
		for file in swiftdoc swiftmodule swiftinterface abi.json; do \
			cp $(THEOS_OBJ_DIR)/$$arch/Cephei.$$file $(THEOS_OBJ_DIR)/Cephei.framework/Modules/Cephei.swiftmodule/$$arch-apple-ios.$$file; \
		done; \
	done

after-Cephei-stage::
ifneq ($(CEPHEI_EMBEDDED),1)
	@# Set up CepheiSpringBoard
	@mkdir -p $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/MobileSubstrate/DynamicLibraries
	@ln -s $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Frameworks/Cephei.framework/Cephei $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/MobileSubstrate/DynamicLibraries/CepheiSpringBoard.dylib
	@cp CepheiSpringBoard.plist $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Library/MobileSubstrate/DynamicLibraries
endif
