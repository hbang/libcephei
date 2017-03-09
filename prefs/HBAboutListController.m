#import "HBAboutListController.h"
#import "HBSupportController.h"
#import <Preferences/PSSpecifier.h>
#import <TechSupport/TechSupport.h>
#include <version.h>

@implementation HBAboutListController

#pragma mark - Constants

+ (NSString *)hb_specifierPlist {
	return @"About";
}

+ (NSURL *)hb_websiteURL {
	return [NSURL URLWithString:@"https://www.hbang.ws/"];
}

+ (NSURL *)hb_donateURL {
	return [NSURL URLWithString:@"https://www.hbang.ws/donate/"];
}

+ (nullable NSString *)hb_supportEmailAddress {
	return nil;
}

+ (nullable TSLinkInstruction *)hb_linkInstruction {
	if ([self hb_supportEmailAddress]) {
		return [HBSupportController linkInstructionForEmailAddress:[self hb_supportEmailAddress]];
	}

	return nil;
}

+ (nullable NSArray <TSIncludeInstruction *> *)hb_supportInstructions {
	return nil;
}

#pragma mark - Callbacks

- (void)hb_openWebsite {
	[[UIApplication sharedApplication] openURL:[self.class hb_websiteURL]];
}

- (void)hb_openDonate {
	[[UIApplication sharedApplication] openURL:[self.class hb_donateURL]];
}

- (void)hb_sendSupportEmail {
	[self hb_sendSupportEmail:nil];
}

- (void)hb_sendSupportEmail:(nullable PSSpecifier *)specifier {
	TSContactViewController *viewController = [HBSupportController supportViewControllerForBundle:[NSBundle bundleForClass:self.class] preferencesIdentifier:specifier.properties[@"defaults"] linkInstruction:[self.class hb_linkInstruction] supportInstructions:[self.class hb_supportInstructions]];

	if ([viewController respondsToSelector:@selector(tintColor)]) {
		viewController.view.tintColor = self.view.tintColor;
	}

	[self.realNavigationController pushViewController:viewController animated:YES];
}

@end
