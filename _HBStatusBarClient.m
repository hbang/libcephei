#import "_HBStatusBarClient.h"

@implementation _HBStatusBarClient

+ (BOOL)hasLibstatusbar {
	static BOOL result = NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		result = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib"];
	});

	return result;
}

@end
