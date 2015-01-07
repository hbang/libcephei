TARGET = iphone:clang:latest:5.0

include theos/makefiles/common.mk

LIBRARY_NAME = libcephei
libcephei_FILES = $(wildcard *.m)
libcephei_FRAMEWORKS = CoreGraphics UIKit

SUBPROJECTS = prefs

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-libcephei-all::
	cp $(THEOS_OBJ_DIR)/libcephei.dylib $(THEOS)/lib

after-stage::
	mkdir -p $(THEOS)/include/Cephei $(THEOS_STAGING_DIR)/usr/include
	rsync -ra *.h {$(THEOS)/include/Cephei,$(THEOS_STAGING_DIR)/usr/include/Cephei}

	ln -s libcephei.dylib $(THEOS_STAGING_DIR)/usr/lib/libhbangcommon.dylib

after-install::
	install.exec "killall Preferences" || true

ifeq ($(DEBUG),1)
	install.exec "sleep 0.2; sbopenurl 'prefs:root=Cephei Demo'"
endif
