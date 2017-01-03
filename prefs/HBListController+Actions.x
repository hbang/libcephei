#import "HBListController+Actions.h"
#import "../HBRespringController.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
@import SafariServices;

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
	NSURL *url = [NSURL URLWithString:specifier.properties[@"url"]];

	// if the url is nil, assert
	NSAssert(url, @"No URL was provided, or it is invalid.");

	// ensure SafariServices is loaded (if it exists)
	[[NSBundle bundleWithPath:@"/System/Library/Frameworks/SafariServices.framework"] load];

	// we can only use SFSafariViewController if it’s available (iOS 9), and the
	// url’s scheme is http(s)
	if (%c(SFSafariViewController) && ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])) {
		// initialise view controller
		SFSafariViewController *viewController = [[%c(SFSafariViewController) alloc] initWithURL:url];

		// use the same tint color as the presenting view controller
		viewController.view.tintColor = self.view.tintColor;

		// present it
		[self.realNavigationController presentViewController:viewController animated:YES completion:nil];
	} else {
		// just do a usual boring openURL:
		[[UIApplication sharedApplication] openURL:url];
	}
}

@end
