@import UIKit;
#include <mach-o/dyld.h>
#import <HBLog.h>

#pragma mark - Hax class

@interface HBForceCepheiPrefs : NSObject

+ (BOOL)forceCepheiPrefsWhichIReallyNeedToAccessAndIKnowWhatImDoingISwear;

@end

@implementation HBForceCepheiPrefs

+ (BOOL)forceCepheiPrefsWhichIReallyNeedToAccessAndIKnowWhatImDoingISwear {
	return NO;
}

@end

#pragma mark - Constructor

%ctor {
	if ([HBForceCepheiPrefs forceCepheiPrefsWhichIReallyNeedToAccessAndIKnowWhatImDoingISwear]) {
		return;
	}

	NSBundle *bundle = [NSBundle mainBundle];
	NSDictionary *info = bundle.infoDictionary;

	if ([@[ @"com.apple.Preferences", @"com.apple.Bridge" ] containsObject:bundle.bundleIdentifier] || info[@"HBUsesCepheiPrefs"]) {
		return;
	}

	// “improperly utilizes the high level preferences API” —wilson
	HBLogWarn(@"CepheiPrefs has possibly been incorrectly loaded into this process! To avoid an annoying warning message, please read the documentation at https://hbang.github.io/libcephei/cepheiprefs-annoying-warning.html.");

	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		// if we’ve been told to shut up, don’t be annoying
		if ([HBForceCepheiPrefs forceCepheiPrefsWhichIReallyNeedToAccessAndIKnowWhatImDoingISwear]) {
			return;
		}

		// try to guess who it is
		NSData *cepheiPrefsData = [@"CepheiPrefs.framework/CepheiPrefs" dataUsingEncoding:NSUTF8StringEncoding];
		NSMutableArray *suspects = [NSMutableArray array];
		uint32_t i = 0;
		const char *imageName;
		while ((imageName = _dyld_get_image_name(i))) {
			NSURL *url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:imageName]];
			NSData *data = [NSData dataWithContentsOfURL:url];
			if (data && [data rangeOfData:cepheiPrefsData options:kNilOptions range:NSMakeRange(0, data.length)].location != NSNotFound) {
				[suspects addObject:url.lastPathComponent.stringByDeletingPathExtension];
			}
			i++;
		}

		// eh, not really worth translating. it should be the case that nobody ever sees this!!
		NSString *title = @"Cephei: Developer Error";
		NSString *mayCrashMessage;

		if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
			mayCrashMessage = [NSString stringWithFormat:@"This can cause %@ to crash to Safe Mode.", [UIDevice currentDevice].localizedModel];
		} else {
			NSDictionary *localizedInfo = bundle.localizedInfoDictionary;
			NSString *appName = localizedInfo[@"CFBundleDisplayName"] ?: info[@"CFBundleDisplayName"] ?: localizedInfo[@"CFBundleName"] ?: info[@"CFBundleName"] ?: info[@"CFBundleExecutable"];
			mayCrashMessage = [NSString stringWithFormat:@"This might cause %@ or other apps to crash.", appName];
		}

		if (suspects.count == 0) {
			[suspects addObject:@"Unknown - A jailbreak hider tweak such as Liberty may be causing suspect detection to not work."];
		}
		
		NSString *message = [NSString stringWithFormat:@"The following tweak(s) contain a programming error (CepheiPrefs framework incorrectly loaded into a process other than Settings):\n\n%@\n\n%@ If you experience issues, try uninstalling these tweak(s) or other recently installed or updated tweaks.", [suspects componentsJoinedByString:@", "], mayCrashMessage];

		// wow remember UIAlertView?!?!
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
	}];
}
