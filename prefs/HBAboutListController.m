#import "HBAboutListController.h"
#import "HBSupportController.h"
#import <Preferences/PSSpecifier.h>
#import <TechSupport/TechSupport.h>
#include <version.h>

@class TSInstruction;

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

+ (NSString *)hb_supportEmailAddress {
	return nil;
}

+ (nullable TSLinkInstruction *)hb_linkInstruction {
	if ([self hb_supportEmailAddress]) {
		return [TSLinkInstruction instructionWithString:[NSString stringWithFormat:@"link email \"%@\" as \"%@\" is_support", [self hb_supportEmailAddress], LOCALIZE(@"EMAIL_SUPPORT", @"About", @"Label for a button that allows the user to email the developer.")]];
	}

	return nil;
}

/*
 TODO: eventually after xcode 7 has been out for a while, this more strict
 type should be used in the header
*/
+ (NSArray <TSInstruction *> *)hb_supportInstructions {
	return @[];
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

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)viewController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
