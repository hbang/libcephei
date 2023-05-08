#import "HBRespringController.h"
#import <SpringBoardServices/SBSRestartRenderServerAction.h>
#import <FrontBoardServices/FBSSystemService.h>
#import <Preferences/PreferencesAppController.h>

@implementation HBRespringController

+ (NSURL *)_preferencesReturnURL {
	Class $PreferencesAppController = NSClassFromString(@"PreferencesAppController");
	if (!$PreferencesAppController) {
		return nil;
	}

	// Ask for the url to be generated. Sadly, this is stored in the preferences, so we need to then
	// read it out of there.
	[(PreferencesAppController *)[$PreferencesAppController sharedApplication] generateURL];
	NSString *position = (__bridge_transfer NSString *)CFPreferencesCopyAppValue(CFSTR("kPreferencePositionKey"), kCFPreferencesCurrentApplication);
	return [NSURL URLWithString:position];
}

+ (void)respring {
	[self respringAndReturnTo:nil];
}

+ (void)respringAndReturnTo:(nullable NSURL *)returnURL {
	// Load FrontBoardServices and SpringBoardServices if necessary.
	[[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/FrontBoardServices.framework"] load];
	[[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/SpringBoardServices.framework"] load];

	Class $FBSSystemService = NSClassFromString(@"FBSSystemService");
	Class $SBSRelaunchAction = NSClassFromString(@"SBSRelaunchAction");
	if ($FBSSystemService && $SBSRelaunchAction) {
		SBSRelaunchAction *restartAction = [$SBSRelaunchAction actionWithReason:@"RestartRenderServer" options:SBSRelaunchActionOptionsFadeToBlackTransition targetURL:returnURL];
		[[$FBSSystemService sharedService] sendActions:[NSSet setWithObject:restartAction] withResult:nil];
	}
}

@end
