TARGET = :clang::4.0

include theos/makefiles/common.mk

SUBPROJECTS = prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	mkdir -p $(THEOS)/include/libhbangcommon
	rsync -rav *.h prefs/*.h $(THEOS)/include/libhbangcommon

after-install::
	install.exec "killall Preferences; sleep 0.2; sbopenurl 'prefs:root=Cydia&path=FlagPaint7'"
