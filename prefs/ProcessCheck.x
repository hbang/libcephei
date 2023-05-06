@import UIKit;
#import <mach-o/dyld.h>
#import <HBLog.h>

#if !ROOTLESS
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

	// Capital One dangerously loads all bundles it sees in [NSBundle allBundles] by accident (!),
	// so just don’t complain in this app
	if ([@[ @"com.apple.Preferences", @"com.apple.Bridge", @"com.capitalone.enterprisemobilebanking" ] containsObject:bundle.bundleIdentifier] || info[@"HBUsesCepheiPrefs"]) {
		return;
	}

	// “improperly utilizes the high level preferences API” —wilson
	HBLogWarn(@"CepheiPrefs has possibly been incorrectly loaded into this process! To avoid an annoying warning message, please read the documentation at https://hbang.github.io/libcephei/cepheiprefs-annoying-warning.html.");

	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		// A tweak can override this method to confirm it really really needs CepheiPrefs.
		if ([HBForceCepheiPrefs forceCepheiPrefsWhichIReallyNeedToAccessAndIKnowWhatImDoingISwear]) {
			return;
		}

		// Try to guess who we can blame here.
		NSData *cepheiPrefsData = [@"CepheiPrefs.framework/CepheiPrefs" dataUsingEncoding:NSUTF8StringEncoding];
		NSMutableArray *suspects = [NSMutableArray array];
		uint32_t i = 0;
		const char *imageName;
		while ((imageName = _dyld_get_image_name(i))) {
			NSURL *url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:imageName]];
			if (![url.path hasSuffix:@"/CepheiPrefs.framework/CepheiPrefs"]) {
				NSData *data = [NSData dataWithContentsOfURL:url];
				if (data && [data rangeOfData:cepheiPrefsData options:kNilOptions range:NSMakeRange(0, data.length)].location != NSNotFound) {
					[suspects addObject:url.lastPathComponent.stringByDeletingPathExtension];
				}
			}
			i++;
		}

		// Eh, not really worth translating. It should be the case that nobody ever sees this!!
		NSString *title = @"Cephei: Developer Error";
		NSString *mayCrashMessage;

		if (IS_SYSTEM_APP) {
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
#endif
