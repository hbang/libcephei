@import Foundation;

NSBundle *cepheiGlobalBundle;

__attribute__((constructor))
static void cepheiInit() {
	cepheiGlobalBundle = [NSBundle bundleWithPath:@INSTALL_PREFIX @"/Library/PreferenceBundles/Cephei.bundle"];
}
