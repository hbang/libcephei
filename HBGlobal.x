#import "HBGlobal.h"

%ctor {
	globalBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/libhbangprefs.bundle"] retain];
}
