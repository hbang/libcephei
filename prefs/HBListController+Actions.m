@import SafariServices;
#import "HBListController+Actions.h"
#import "HBAppearanceSettings.h"
#import "../HBRespringController.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#include <objc/runtime.h>

@interface HBRespringController ()

+ (NSURL *)_preferencesReturnURL;

@end

@implementation HBListController (Actions)

#pragma mark - Respring

- (void)hb_respring:(PSSpecifier *)specifier {
	[self _hb_respringAndReturn:NO specifier:specifier];
}

- (void)hb_respringAndReturn:(PSSpecifier *)specifier {
	[self _hb_respringAndReturn:YES specifier:specifier];
}

- (void)_hb_respringAndReturn:(BOOL)returnHere specifier:(PSSpecifier *)specifier {
	PSTableCell *cell = [self cachedCellForSpecifier:specifier];

	// disable the cell, in case it takes a moment
	cell.cellEnabled = NO;

	// call the main method
	[HBRespringController respringAndReturnTo:returnHere ? [HBRespringController _preferencesReturnURL] : nil];
}

#pragma mark - Open URL

- (void)hb_openURL:(PSSpecifier *)specifier {
	// get the url from the specifier
	NSURL *url = specifier.properties[@"url"];
	if ([url isKindOfClass:NSString.class]) {
		url = [NSURL URLWithString:(NSString *)url];
	}

	// if the url is nil, assert
	NSAssert(url != nil && [url isKindOfClass:NSURL.class], @"No URL was provided, or it is invalid.");

	if ([UIApplication instancesRespondToSelector:@selector(openURL:options:completionHandler:)]) {
		// Attempt to open as a universal link, falling back to open in browser.
		[[UIApplication sharedApplication] openURL:url options:@{ UIApplicationOpenURLOptionUniversalLinksOnly: @YES } completionHandler:^(BOOL success) {
			if (!success) {
				[self _hb_openURLInBrowser:url];
			}
		}];
	} else {
		[self _hb_openURLInBrowser:url];
	}
}

- (void)_hb_openURLInBrowser:(NSURL *)url {
	// ensure SafariServices is loaded (if it exists)
	[[NSBundle bundleWithPath:@"/System/Library/Frameworks/SafariServices.framework"] load];
	Class $SFSafariViewController = objc_getClass("SFSafariViewController");

	// we can only use SFSafariViewController if it’s available (iOS 9), and the url scheme is http(s)
	if ($SFSafariViewController != nil && ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])) {
		// initialise view controller
		SFSafariViewController *viewController = [[$SFSafariViewController alloc] initWithURL:url];

		// use the same tint color as the presenting view controller
		if ([viewController respondsToSelector:@selector(setPreferredControlTintColor:)]) {
			viewController.preferredControlTintColor = self.hb_appearanceSettings.navigationBarTintColor ?: self.view.tintColor;
			viewController.preferredBarTintColor = self.hb_appearanceSettings.navigationBarBackgroundColor;
		}

		// present it
		[self.realNavigationController presentViewController:viewController animated:YES completion:nil];
	} else {
#ifdef THEOS
		// just do a usual boring openURL:
		[[UIApplication sharedApplication] openURL:url];
#endif
	}
}

@end
