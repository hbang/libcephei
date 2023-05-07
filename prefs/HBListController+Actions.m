@import SafariServices;
#import "HBListController+Actions.h"
#import "HBAppearanceSettings.h"
#import "../HBRespringController.h"
#import "../NSDictionary+HBAdditions.h"
#import "../NSString+HBAdditions.h"
#import <MobileCoreServices/LSApplicationProxy.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <UIKit/UIAlertAction+Private.h>
#import <UIKit/UIImage+Private.h>

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
	// Disable the cell, in case it takes a moment
	PSTableCell *cell = [self cachedCellForSpecifier:specifier];
	cell.cellEnabled = NO;

	[HBRespringController respringAndReturnTo:returnHere ? [HBRespringController _preferencesReturnURL] : nil];
}

#pragma mark - Open URL

- (void)hb_openURL:(PSSpecifier *)specifier {
	// Get the url from the specifier
	NSURL *url = specifier.properties[@"url"];
	if ([url isKindOfClass:NSString.class]) {
		url = [NSURL URLWithString:(NSString *)url];
	}
	NSAssert(url != nil && [url isKindOfClass:NSURL.class], @"No URL was provided, or it is invalid.");

	// Attempt to open as a universal link, falling back to open in browser.
	[[UIApplication sharedApplication] openURL:url options:@{ UIApplicationOpenURLOptionUniversalLinksOnly: @YES } completionHandler:^(BOOL success) {
		if (!success) {
			[self _hb_openURLInBrowser:url];
		}
	}];
}

- (void)_hb_openURLInBrowser:(NSURL *)url {
	// Load SafariServices (if it exists)
	[[NSBundle bundleWithPath:@"/System/Library/Frameworks/SafariServices.framework"] load];

	// We can only use SFSafariViewController if it’s available (iOS 9), and the url scheme is http(s)
	if ([SFSafariViewController class] != nil && ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])) {
		SFSafariViewController *viewController = [[SFSafariViewController alloc] initWithURL:url];
		viewController.preferredControlTintColor = self.hb_appearanceSettings.navigationBarTintColor ?: self.view.tintColor;
		viewController.preferredBarTintColor = self.hb_appearanceSettings.navigationBarBackgroundColor;

		[self.realNavigationController presentViewController:viewController animated:YES completion:nil];
	} else {
#ifdef THEOS
		// Just do a usual boring openURL:
		[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
#endif
	}
}

- (void)hb_openPackage:(PSSpecifier *)specifier {
	NSString *identifier = specifier.properties[@"packageIdentifier"];
	NSString *repo = specifier.properties[@"packageRepository"];
	NSString *escapedIdentifier = identifier.hb_stringByEncodingQueryPercentEscapes;

	NSArray <NSArray <id> *> *packageManagerURLs = repo == nil
		? @[
			@[ @"org.coolstar.SileoStore", [NSURL URLWithString:[@"sileo://package/" stringByAppendingString:escapedIdentifier]] ],
			@[ @"xyz.willy.Zebra", [NSURL URLWithString:[@"zbra://package/" stringByAppendingString:escapedIdentifier]] ]
		]
		: @[
			@[ @"org.coolstar.SileoStore", [NSURL URLWithString:[@"sileo://package/" stringByAppendingString:escapedIdentifier]] ],
			@[ @"xyz.willy.Zebra", [NSURL URLWithString:[NSString stringWithFormat:@"zbra://package/%@?%@", escapedIdentifier, @{
					@"source": repo
				}.hb_queryString]] ]
		];

	NSString *title = LOCALIZE(@"OPEN_PACKAGE_IN_TITLE", @"PackageCell", @"");
	NSString *message = repo == nil ? nil : [NSString stringWithFormat:LOCALIZE(@"OPEN_PACKAGE_IN_REPO_NOTICE", @"PackageCell", @""), repo];
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];

	for (NSArray <id> *item in packageManagerURLs) {
		NSString *bundleIdentifier = item[0];
		NSURL *url = item[1];
		LSApplicationProxy *app = [LSApplicationProxy applicationProxyForIdentifier:bundleIdentifier];
		if (app == nil || !app.isInstalled) {
			continue;
		}

		NSString *name = app.localizedName;
		UIImage *icon = [[UIImage _applicationIconImageForBundleIdentifier:bundleIdentifier format:MIIconVariantSmall scale:self.view.window.screen.scale] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		UIAlertAction *action = [UIAlertAction _actionWithTitle:name descriptiveText:nil image:icon style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self _hb_openURLInBrowser:url];
		} shouldDismissHandler:nil];
		[alertController addAction:action];
	}

	NSBundle *uikitBundle = [NSBundle bundleWithIdentifier:@"com.apple.UIKit"];
	NSString *cancel = [uikitBundle localizedStringForKey:@"Cancel" value:@"" table:@"Localizable"];
	[alertController addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alertController animated:YES completion:nil];
}

@end
