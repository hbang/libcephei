# ugly hack so we get Cephei{,Prefs}_PUBLIC_HEADERS :/
include Makefile
include prefs/Makefile

APPLEDOCFILES = $(Cephei_PUBLIC_HEADERS) $(foreach header,$(CepheiPrefs_PUBLIC_HEADERS),prefs/$(header))

DOCS_STAGING_DIR = _docs
DOCS_OUTPUT_PATH = docs

all:: docs

docs: $(APPLEDOCFILES)
	# eventually, this should probably be in theos.
	# for now, this is good enough :p

	[[ -d "$(DOCS_STAGING_DIR)" ]] && rm -r "$(DOCS_STAGING_DIR)" || true

	-appledoc --project-name Cephei --project-company "HASHBANG Productions" --company-id ws.hbang --project-version 1.2 --no-install-docset \
		--keep-intermediate-files --create-html --publish-docset --docset-feed-url "https://hbang.github.io/libcephei/xcode-docset.atom" \
		--docset-atom-filename xcode-docset.atom --docset-package-url "https://hbang.github.io/libcephei/docset.xar" \
		--docset-package-filename docset --docset-fallback-url "https://hbang.github.io/libcephei/" --docset-feed-name Cephei \
		--index-desc README.md --no-repeat-first-par \
		--output "$(DOCS_STAGING_DIR)" $<

	[[ -d "$(DOCS_OUTPUT_PATH)" ]] || git clone -b gh-pages git@github.com:hbang/libcephei.git "$(DOCS_OUTPUT_PATH)"
	rsync -ra "$(DOCS_STAGING_DIR)"/{html,publish}/ "$(DOCS_OUTPUT_PATH)"
	rm -r "$(DOCS_STAGING_DIR)"
