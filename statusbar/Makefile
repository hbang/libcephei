INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

export ADDITIONAL_CFLAGS = -Wextra -Wno-unused-parameter -fobjc-arc -I$(THEOS_PROJECT_DIR) -I$(THEOS_PROJECT_DIR)/..

TWEAK_NAME = libstatusbar

libstatusbar_FILES = $(wildcard *.[xm])
libstatusbar_EXTRA_FRAMEWORKS = Cephei
libstatusbar_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk
