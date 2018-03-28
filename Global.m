NSBundle *globalBundle;

__attribute__((constructor))
static void cepheiInit() {
	globalBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/Cephei.bundle"];
}
