#import "HBGlobal.h"
#import "HBAboutListController.h"
#import "HBOutputForShellCommand.h"
#import <MobileGestalt/MobileGestalt.h>
#include <version.h>

@implementation HBAboutListController

#pragma mark - Constants

+ (NSURL *)hb_websiteURL {
	return [NSURL URLWithString:@"https://www.hbang.ws"];
}

+ (NSURL *)hb_donateURL {
	return [NSURL URLWithString:@"https://www.hbang.ws/donate"];
}

+ (NSString *)hb_supportEmailAddress {
	return @"HASHBANG Productions Support <support@hbang.ws>";
}

#pragma mark - PSListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"About" target:self] retain];
	}

	return _specifiers;
}

#pragma mark - Callbacks

- (void)hb_openWebsite {
	[[UIApplication sharedApplication] openURL:[self.class hb_websiteURL]];
}

- (void)hb_openDonate {
	[[UIApplication sharedApplication] openURL:[self.class hb_donateURL]];
}

- (void)hb_sendSupportEmail {
	if (![MFMailComposeViewController canSendMail]) {
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:L18N(@"No mail accounts are set up.") message:L18N(@"Use the Mail settings to add a new account.") delegate:nil cancelButtonTitle:L18N(@"OK") otherButtonTitles:nil] autorelease];
		[alertView show];

		return;
	}

	NSDictionary *info = [NSBundle bundleForClass:self.class].infoDictionary;

	MFMailComposeViewController *viewController = [[[MFMailComposeViewController alloc] init] autorelease];
	viewController.mailComposeDelegate = self;
	viewController.toRecipients = @[ [self.class hb_supportEmailAddress] ];
	viewController.subject = [NSString stringWithFormat:L18N(@"%@ %@ Support"), info[@"CFBundleName"], HBOutputForShellCommand([NSString stringWithFormat:@"/usr/bin/dpkg-query -f '${Version}' -W '%@'", info[@"HBPackageIdentifier"] ?: info[@"CFBundleIdentifier"]])];
	[viewController addAttachmentData:[HBOutputForShellCommand(@"/usr/bin/dpkg -l") dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:@"dpkgl.txt"];

	NSString *product = nil, *version = nil, *build = nil;

	if (IS_IOS_OR_NEWER(iOS_6_0)) {
		product = (NSString *)MGCopyAnswer(kMGProductType);
		version = (NSString *)MGCopyAnswer(kMGProductVersion);
		build = (NSString *)MGCopyAnswer(kMGBuildVersion);
	} else {
		product = [UIDevice currentDevice].localizedModel;
		version = [UIDevice currentDevice].systemVersion;
		build = @"?";
	}

	[viewController setMessageBody:[NSString stringWithFormat:L18N(@"\n\nDevice information: %@, iOS %@ (%@)"), product, version, build] isHTML:NO];

	if (IS_MOST_MODERN) {
		[self.navigationController.navigationController presentViewController:viewController animated:YES completion:nil];
	}

	else {
		[self.navigationController presentViewController:viewController animated:YES completion:nil];
	}
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)viewController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
