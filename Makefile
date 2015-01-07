TARGET = iphone:clang:latest:5.0

include theos/makefiles/common.mk

SUBPROJECTS = prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	mkdir -p $(THEOS)/include/libcephei $(THEOS_STAGING_DIR)/usr/include
	rsync -ra *.h prefs/*.h {$(THEOS)/include/Cephei,$(THEOS_STAGING_DIR)/usr/include/Cephei}

	ln -s libcephei.dylib $(THEOS_STAGING_DIR)/usr/lib/libhbangcommon.dylib

after-install::
	install.exec "killall Preferences" || true

ifeq ($(DEBUG),1)
	install.exec "sleep 0.2; sbopenurl 'prefs:root=Cephei Demo'"
endif
