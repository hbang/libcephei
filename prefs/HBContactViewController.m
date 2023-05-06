#import "HBContactViewController.h"
#import "HBAppearanceSettings.h"
#import "../HBOutputForShellCommand.h"
#import <version.h>
@import MessageUI;

@interface HBContactViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation HBContactViewController {
	BOOL _hasShown;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	if (IS_IOS_OR_NEWER(iOS_8_0) && (self.navigationController == nil || self.navigationController.viewControllers.count == 1)) {
		self.view.hidden = YES;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (_hasShown) {
		return;
	}

	// No use doing this if we can’t send email.
	if (![MFMailComposeViewController canSendMail]) {
		NSString *title = LOCALIZE(@"NO_EMAIL_ACCOUNTS_TITLE", @"Support", @"");
		NSString *body = LOCALIZE(@"NO_EMAIL_ACCOUNTS_BODY", @"Support", @"");
		NSBundle *uikitBundle = [NSBundle bundleWithIdentifier:@"com.apple.UIKit"];
		NSString *ok = [uikitBundle localizedStringForKey:@"OK" value:@"" table:@"Localizable"];
		if ([UIAlertController class] != nil) {
			UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleAlert];
			[alertController addAction:[UIAlertAction actionWithTitle:ok style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
				[self _dismiss];
			}]];
			[self presentViewController:alertController animated:YES completion:nil];
		} else {
#if !ROOTLESS
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:body delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
			[alertView show];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self _dismiss];
			});
#endif
		}
		return;
	}

	MFMailComposeViewController *viewController = [[MFMailComposeViewController alloc] init];
	viewController.mailComposeDelegate = self;
	viewController.toRecipients = @[ _to ];
	viewController.subject = _subject;
	[viewController setMessageBody:_messageBody isHTML:NO];
	[viewController addAttachmentData:[HBOutputForShellCommand(@INSTALL_PREFIX @"/usr/bin/dpkg -l") dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:@"Package List.txt"];
	if (_preferencesPlist != nil && _preferencesIdentifier != nil) {
		[viewController addAttachmentData:_preferencesPlist mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"preferences-%@.plist", _preferencesIdentifier]];
	}
	if ([viewController.view respondsToSelector:@selector(tintColor)]) {
		viewController.navigationBar.tintColor = self.hb_appearanceSettings.navigationBarTintColor ?: self.view.tintColor;
		viewController.navigationBar.barTintColor = self.hb_appearanceSettings.navigationBarBackgroundColor;
		viewController.view.tintColor = self.view.tintColor;
	}

	[self presentViewController:viewController animated:YES completion:nil];
	_hasShown = YES;
}

- (void)_dismiss {
	if (self.navigationController == nil || self.navigationController.viewControllers.count == 1) {
		[self dismissViewControllerAnimated:NO completion:nil];
	} else {
		[self.realNavigationController popViewControllerAnimated:YES];
	}
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)viewController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[viewController dismissViewControllerAnimated:YES completion:nil];
	[self _dismiss];
}

@end
