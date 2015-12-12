TARGET = iphone:clang:latest:5.0

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = Cephei
Cephei_FILES = $(wildcard *.m) Global.x $(wildcard CompactConstraint/*.m)
Cephei_PUBLIC_HEADERS = HBOutputForShellCommand.h HBPreferences.h UIColor+HBAdditions.h $(wildcard CompactConstraint/*.h)
Cephei_FRAMEWORKS = CoreGraphics UIKit
Cephei_CFLAGS = -include Global.h

CompactConstraint/NSLayoutConstraint+CompactConstraint.m_CFLAGS = -fobjc-arc
CompactConstraint/UIView+CompactConstraint.m_CFLAGS = -fobjc-arc

SUBPROJECTS = prefs

include $(THEOS_MAKE_PATH)/framework.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

ifeq ($(DOCS),1)
# ugly hack so we get CepheiPrefs_PUBLIC_HEADERS :/
include prefs/Makefile

APPLEDOCFILES = $(Cephei_PUBLIC_HEADERS) $(foreach header,$(CepheiPrefs_PUBLIC_HEADERS),prefs/$(header))

DOCS_STAGING_DIR = _docs
DOCS_OUTPUT_PATH = docs
endif

after-Cephei-all::
	# create directories
	mkdir -p $(THEOS_OBJ_DIR)/Cephei.framework/Headers

	# copy headers
	rsync -ra $(Cephei_PUBLIC_HEADERS) $(THEOS_OBJ_DIR)/Cephei.framework/Headers

	# copy to theos lib dir
	rsync -ra $(THEOS_OBJ_DIR)/Cephei.framework $(THEOS)/lib

after-Cephei-stage::
	# create directories
	mkdir -p $(THEOS_STAGING_DIR)/usr/{include,lib}

	# libhbangcommon.dylib -> libcephei.dylib
	ln -s libcephei.dylib $(THEOS_STAGING_DIR)/usr/lib/libhbangcommon.dylib

	# libcephei.dylib -> Cephei.framework
	ln -s /Library/Frameworks/Cephei.framework/Cephei $(THEOS_STAGING_DIR)/usr/lib/libcephei.dylib

	# Cephei -> Cephei.framework/Headers
	ln -s /Library/Frameworks/Cephei.framework/Headers $(THEOS_STAGING_DIR)/usr/include/Cephei

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences" || true

ifneq ($(DEBUG),0)
	install.exec "sleep 0.2; sbopenurl 'prefs:root=Cephei Demo'"
endif
else
	install.exec spring
endif

docs::
	# eventually, this should probably be in theos.
	# for now, this is good enough :p

ifneq ($(DOCS),1)
$(error Please set DOCS=1 (sorry))
endif

	[[ -d "$(DOCS_STAGING_DIR)" ]] && rm -r "$(DOCS_STAGING_DIR)" || true

	-appledoc --project-name Cephei --project-company "HASHBANG Productions" --company-id ws.hbang --project-version 1.2 --no-install-docset \
		--keep-intermediate-files --create-html --publish-docset --docset-feed-url "https://hbang.github.io/libcephei/xcode-docset.atom" \
		--docset-atom-filename xcode-docset.atom --docset-package-url "https://hbang.github.io/libcephei/docset.xar" \
		--docset-package-filename docset --docset-fallback-url "https://hbang.github.io/libcephei/" --docset-feed-name Cephei \
		--index-desc README.md --no-repeat-first-par \
		--output "$(DOCS_STAGING_DIR)" $(APPLEDOCFILES)

	[[ -d "$(DOCS_OUTPUT_PATH)" ]] || git clone -b gh-pages git@github.com:hbang/libcephei.git "$(DOCS_OUTPUT_PATH)"
	rsync -ra "$(DOCS_STAGING_DIR)"/{html,publish}/ "$(DOCS_OUTPUT_PATH)"
	rm -r "$(DOCS_STAGING_DIR)"
