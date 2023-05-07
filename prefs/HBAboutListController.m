#import "HBAboutListController.h"
#import "HBAppearanceSettings.h"
#import "HBSupportController.h"
#import "HBContactViewController.h"
#import <Preferences/PSSpecifier.h>
#import <version.h>

@implementation HBAboutListController

#pragma mark - Constants

+ (NSString *)hb_specifierPlist {
	return @"About";
}

+ (nullable NSString *)hb_supportEmailAddress {
	return nil;
}

#pragma mark - Callbacks

- (void)hb_sendSupportEmail {
	[self hb_sendSupportEmail:nil];
}

- (void)hb_sendSupportEmail:(nullable PSSpecifier *)specifier {
	HBContactViewController *viewController = (HBContactViewController *)[HBSupportController supportViewControllerForBundle:[NSBundle bundleForClass:self.class] preferencesIdentifier:specifier.properties[@"defaults"] sendToEmail:[self.class hb_supportEmailAddress]];
	viewController.hb_appearanceSettings = self.hb_appearanceSettings;
	viewController.overrideUserInterfaceStyle = self.overrideUserInterfaceStyle;
	[self.realNavigationController presentViewController:viewController animated:NO completion:nil];
}

@end
