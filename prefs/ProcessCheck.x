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
		NSArray <NSURL *> *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL URLWithString:@"file:///usr/lib/TweakInject/"] includingPropertiesForKeys:nil options:kNilOptions error:nil];

		if (!contents) {
			contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL URLWithString:@"file:///Library/MobileSubstrate/DynamicLibraries/"] includingPropertiesForKeys:nil options:kNilOptions error:nil];
		}

		NSData *cepheiPrefsData = [@"CepheiPrefs.framework/CepheiPrefs" dataUsingEncoding:NSUTF8StringEncoding];
		NSMutableArray *suspects = [NSMutableArray array];

		for (NSURL *url in contents) {
			NSData *data = [NSData dataWithContentsOfURL:url];
			if (data && [data rangeOfData:cepheiPrefsData options:kNilOptions range:NSMakeRange(0, data.length)].location != NSNotFound) {
				[suspects addObject:url.lastPathComponent.stringByDeletingPathExtension];
			}
		}

		// eh, not really worth translating. it should be the case that nobody ever sees this!!
		NSString *title = @"Cephei: Developer Error";
		NSString *mayCrashMessage;

		if (IN_SPRINGBOARD) {
			mayCrashMessage = [NSString stringWithFormat:@"This can cause %@ to crash to Safe Mode.", [UIDevice currentDevice].localizedModel];
		} else {
			NSDictionary *localizedInfo = bundle.localizedInfoDictionary;
			NSString *appName = localizedInfo[@"CFBundleDisplayName"] ?: info[@"CFBundleDisplayName"] ?: localizedInfo[@"CFBundleName"] ?: info[@"CFBundleName"] ?: info[@"CFBundleExecutable"];
			mayCrashMessage = [NSString stringWithFormat:@"This might cause %@ or other apps to crash.", appName];
		}

		NSString *message;
		
		if (suspects.count > 0) {
			message = [NSString stringWithFormat:@"The following tweak(s) contain a programming error (CepheiPrefs framework incorrectly loaded into a process other than Settings):\n\n%@\n\n%@ If you experience issues, try uninstalling these tweak(s) or other recently installed or updated tweaks.", [suspects componentsJoinedByString:@", "], mayCrashMessage];
		} else {
			message = [NSString stringWithFormat:@"A tweak you’ve installed contains a programming error (CepheiPrefs framework incorrectly loaded into a process other than Settings).\n\n%@ If you experience issues, try uninstalling recently installed or updated tweaks.", mayCrashMessage];
		}

		// wow remember UIAlertView?!?!
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
	}];
}
