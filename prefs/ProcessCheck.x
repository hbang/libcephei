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
	HBLogWarn(@"CepheiPrefs has been loaded into a process other than Preferences! Are you sure I’m meant to be here? Crash is possible.");

	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		// if we’ve been told to shut up, don’t be annoying
		if ([HBForceCepheiPrefs forceCepheiPrefsWhichIReallyNeedToAccessAndIKnowWhatImDoingISwear]) {
			return;
		}

		// eh, not really worth translating. it should be the case that nobody ever sees this!!
		NSString *title = @"Cephei: Developer Error";
		NSString *message;
		
		if (IN_SPRINGBOARD) {
			message = [NSString stringWithFormat:@"A tweak you’ve installed contains a programming error (CepheiPrefs framework loaded into a process other than Settings). This can cause %@ to crash to Safe Mode.\n\nIf you experience issues, try uninstalling recently installed or updated tweaks.", [UIDevice currentDevice].localizedModel];
		} else {
			NSDictionary *localizedInfo = bundle.localizedInfoDictionary;
			NSString *appName = localizedInfo[@"CFBundleDisplayName"] ?: info[@"CFBundleDisplayName"] ?: localizedInfo[@"CFBundleName"] ?: info[@"CFBundleName"] ?: info[@"CFBundleExecutable"];

			message = [NSString stringWithFormat:@"A tweak you’ve installed contains a programming error (CepheiPrefs framework loaded into a process other than Settings). This might cause %@ or other apps to crash.\n\nIf you experience issues, try uninstalling recently installed or updated tweaks.", appName];
		}

		// wow remember UIAlertView?!?!
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
	}];
}
