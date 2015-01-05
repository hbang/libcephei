THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang::4.0

include theos/makefiles/common.mk

SUBPROJECTS = prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	mkdir -p $(THEOS)/include/libhbangcommon $(THEOS_STAGING_DIR)/usr/include
	rsync -ra *.h prefs/*.h {$(THEOS)/include/libhbangcommon,$(THEOS_STAGING_DIR)/usr/include/libcephei}

	ln -s libcephei.dylib $(THEOS_STAGING_DIR)/usr/lib/libhbangcommon.dylib

after-install::
	install.exec "killall Preferences"
