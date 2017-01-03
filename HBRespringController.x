#import "HBRespringController.h"
#import "HBOutputForShellCommand.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoardServices/SBSRestartRenderServerAction.h>
#import <FrontBoardServices/FBSSystemService.h>
#import <Preferences/PreferencesAppController.h>
#include <notify.h>

@implementation HBRespringController

+ (NSURL *)_preferencesReturnURL {
	// not much we can do if we're not in settings
	if (!%c(PreferencesAppController)) {
		return nil;
	}

	// ask for the url to be generated
	[(PreferencesAppController *)[UIApplication sharedApplication] generateURL];

	// sadly, this is stored in the preferences...
	NSString *position = (__bridge NSString *)CFPreferencesCopyAppValue(CFSTR("kPreferencePositionKey"), kCFPreferencesCurrentApplication);

	// return it back into a url
	return [NSURL URLWithString:position];
}

+ (void)respring {
	[self respringAndReturnTo:nil];
}

+ (void)respringAndReturnTo:(nullable NSURL *)returnURL {
	// if we have frontboard (iOS 8)
	if (%c(SBSRestartRenderServerAction) && %c(FBSSystemService)) {
		// ask for a render server (aka springboard) restart. if requested, provide
		// our url so settings is opened right back up to here
		// TODO: ??? why can't i link these? they're in the sdk
		SBSRestartRenderServerAction *restartAction = [%c(SBSRestartRenderServerAction) restartActionWithTargetRelaunchURL:returnURL];
		[[%c(FBSSystemService) sharedService] sendActions:[NSSet setWithObject:restartAction] withResult:nil];
	} else if (IN_SPRINGBOARD) {
		// in springboard, use good ole _relaunchSpringBoardNow
		SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
		[app _relaunchSpringBoardNow];
	} else {
		// send a notification to our little listener in springboard, which may or
		// may not be there
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("ws.hbang.common/Respring"), NULL, NULL, TRUE);

		// wait half a second
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC / 2)), dispatch_get_main_queue(), ^{
			// manually execute killall (i'm lazy, sorry)
			HBOutputForShellCommand(@"/bin/killall SpringBoard");
		});
	}
}

@end

#pragma mark - Respring server

%ctor {
	%init;

	// if we're in springboard without the FrontBoard restart action (iOS < 8)
	if (IN_SPRINGBOARD && !%c(SBSRestartRenderServerAction)) {
		// register our notification
		int notifyToken;
		notify_register_dispatch("ws.hbang.common/Respring", &notifyToken, dispatch_get_main_queue(), ^(int token) {
			// call good ole _relaunchSpringBoardNow
			SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
			[app _relaunchSpringBoardNow];
		});
	}
}
