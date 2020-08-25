@import Foundation;

NSBundle *cepheiGlobalBundle;

__attribute__((constructor))
static void cepheiInit() {
	cepheiGlobalBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/Cephei.bundle"];
}
