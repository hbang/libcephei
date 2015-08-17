TARGET = iphone:clang:latest:5.0

APPLEDOCFILES = $(wildcard *.h) $(wildcard prefs/*.h)
DOCS_STAGING_DIR = _docs
DOCS_OUTPUT_PATH = docs

include theos/makefiles/common.mk

LIBRARY_NAME = libcephei
libcephei_FILES = $(wildcard *.m)
libcephei_FRAMEWORKS = CoreGraphics UIKit

SUBPROJECTS = prefs

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-libcephei-all::
ifneq ($(DEBUG),1)
	cp $(THEOS_OBJ_DIR)/libcephei.dylib $(THEOS)/lib/libcephei.dylib
endif

after-stage::
	mkdir -p $(THEOS)/include/Cephei $(THEOS_STAGING_DIR)/usr/include/Cephei
	rsync -ra *.h $(THEOS_STAGING_DIR)/usr/include/Cephei/ --exclude HBGlobal.h
	rsync -ra $(THEOS_STAGING_DIR)/usr/include/Cephei/ $(THEOS)/include/Cephei

	ln -s libcephei.dylib $(THEOS_STAGING_DIR)/usr/lib/libhbangcommon.dylib

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences" || true

ifeq ($(DEBUG),1)
	install.exec "sleep 0.2; sbopenurl 'prefs:root=Cephei Demo'"
endif
else
	install.exec spring
endif

docs::
	# eventually, this should probably be in theos.
	# for now, this is good enough :p

	[[ -d "$(DOCS_STAGING_DIR)" ]] && rm -r "$(DOCS_STAGING_DIR)" || true

	-appledoc --project-name Cephei --project-company "HASHBANG Productions" --company-id ws.hbang --project-version 1.2 --no-install-docset \
		--keep-intermediate-files --create-html --publish-docset --docset-feed-url "https://hbang.github.io/libcephei/xcode-docset.atom" \
		--docset-atom-filename xcode-docset.atom --docset-package-url "https://hbang.github.io/libcephei/docset.xar" \
		--docset-package-filename docset --docset-fallback-url "https://hbang.github.io/libcephei/" --docset-feed-name Cephei \
		--keep-undocumented-objects --keep-undocumented-members --search-undocumented-doc --index-desc README.md --no-repeat-first-par \
		--output "$(DOCS_STAGING_DIR)" $(APPLEDOCFILES)

	[[ -d "$(DOCS_OUTPUT_PATH)" ]] || git clone -b gh-pages git@github.com:hbang/libcephei.git "$(DOCS_OUTPUT_PATH)"
	rsync -ra "$(DOCS_STAGING_DIR)"/{html,publish}/ "$(DOCS_OUTPUT_PATH)"
	rm -r "$(DOCS_STAGING_DIR)"
