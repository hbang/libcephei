@import Foundation;
#import <objc/runtime.h>

#if !ROOTLESS
__attribute__((constructor))
static void cepheiUIInit() {
	if (objc_getClass("UIApplication")) {
		[[NSBundle bundleWithPath:@"/usr/lib/CepheiUI.framework"] load];
	}
}
#endif
