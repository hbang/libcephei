@import UIKit;
#import "HBRespringController.h"
#import "HBOutputForShellCommand.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoardServices/SBSRestartRenderServerAction.h>
#import <FrontBoardServices/FBSSystemService.h>
#import <Preferences/PreferencesAppController.h>
#import <notify.h>

@implementation HBRespringController

+ (NSURL *)_preferencesReturnURL {
	// not much we can do if we're not in settings
	if (!%c(PreferencesAppController)) {
		return nil;
	}

	// ask for the url to be generated
	[(PreferencesAppController *)[%c(UIApplication) sharedApplication] generateURL];

	// sadly, this is stored in the preferences…
	NSString *position = (__bridge NSString *)CFPreferencesCopyAppValue(CFSTR("kPreferencePositionKey"), kCFPreferencesCurrentApplication);

	// return it back into a url
	return [NSURL URLWithString:position];
}

+ (void)respring {
	[self respringAndReturnTo:nil];
}

+ (void)respringAndReturnTo:(nullable NSURL *)returnURL {
	// Load FrontBoardServices and SpringBoardServices if necessary.
	[[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/FrontBoardServices.framework"] load];
	[[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/SpringBoardServices.framework"] load];

	if (%c(FBSSystemService)) {
		// iOS 8+: Ask for a system app (SpringBoard, etc.) restart, providing our return URL if any.
		// Despite being called SpringBoardServices, the framework appears to exist and work on iOS
		// variants that use a system app other than SpringBoard.
		SBSRelaunchAction *restartAction;
		if (%c(SBSRelaunchAction)) { // 9.3+
			restartAction = [%c(SBSRelaunchAction) actionWithReason:@"RestartRenderServer" options:SBSRelaunchActionOptionsFadeToBlackTransition targetURL:returnURL];
		} else if (%c(SBSRestartRenderServerAction)) { // 8.0 – 9.3
			restartAction = [%c(SBSRestartRenderServerAction) restartActionWithTargetRelaunchURL:returnURL];
		}
		[[%c(FBSSystemService) sharedService] sendActions:[NSSet setWithObject:restartAction] withResult:nil];
	} else {
		// iOS 5.0 – 7.1: Do our best to restart using whatever we have available. If we’re in
		// SpringBoard, use good ole _relaunchSpringBoardNow. If not, we need to post to our listener
		// in SpringBoard, which may or may not be there. If that doesn’t seem to do anything within
		// 500ms, fall back to running killall SpringBoard.
		if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		[(SpringBoard *)[%c(UIApplication) sharedApplication] _relaunchSpringBoardNow];
	} else {
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("ws.hbang.common/Respring"), NULL, NULL, TRUE);

			// Wait half a second in case that fails, so we can manually execute a killall. In future, we
			// could use liblaunch here instead to stop and restart the com.apple.SpringBoard job.
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * 0.5)), dispatch_get_main_queue(), ^{
				HBOutputForShellCommand(@"/bin/killall SpringBoard");
			});
	}
	}
}

@end

#pragma mark - Respring server

%ctor {
	%init;

	// For iOS 5.0 – 7.1, run a listener in SpringBoard that calls _relaunchSpringBoardNow on posting
	// a notification. This handles the situation of HBRespringController being called from a
	// non-SpringBoard process, such as Preferences.
	if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"] && !%c(FBSSystemService)) {
		int notifyToken;
		notify_register_dispatch("ws.hbang.common/Respring", &notifyToken, dispatch_get_main_queue(), ^(int token) {
			[(SpringBoard *)[%c(UIApplication) sharedApplication] _relaunchSpringBoardNow];
		});
	}
}
