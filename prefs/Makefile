TARGET = :clang::5.0
ARCHS = armv7 arm64

include theos/makefiles/common.mk

LIBRARY_NAME = libhbangprefs
libhbangprefs_FILES = $(wildcard *.x) $(wildcard *.m)
libhbangprefs_FRAMEWORKS = CoreGraphics MessageUI UIKit
libhbangprefs_PRIVATE_FRAMEWORKS = Preferences
libhbangprefs_CFLAGS = -include HBGlobal.h
libhbangprefs_LDFLAGS = -weak_framework Twitter
libhbangprefs_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/library.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceBundles/libhbangprefs.bundle
	rsync -rav Resources/ $(THEOS_STAGING_DIR)/Library/PreferenceBundles/libhbangprefs.bundle
	ln -s /usr/lib/libhbangprefs.dylib $(THEOS_STAGING_DIR)/Library/PreferenceBundles/libhbangprefs.bundle/libhbangprefs

	cp $(THEOS_OBJ_DIR)/libhbangprefs.dylib $(THEOS)/lib/libhbangprefs.dylib
