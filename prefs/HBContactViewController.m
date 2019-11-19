#import "HBContactViewController.h"
#import "../HBOutputForShellCommand.h"
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (_hasShown) {
		return;
	}

	MFMailComposeViewController *viewController = [[MFMailComposeViewController alloc] init];
	viewController.mailComposeDelegate = self;
	viewController.toRecipients = @[ _to ];
	viewController.subject = _subject;
	[viewController setMessageBody:_messageBody isHTML:NO];
	[viewController addAttachmentData:[HBOutputForShellCommand(@"/usr/bin/dpkg -l") dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:@"Package List.txt"];
	if (_preferencesPlist != nil && _preferencesIdentifier != nil) {
		[viewController addAttachmentData:_preferencesPlist mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"preferences-%@.plist", _preferencesIdentifier]];
	}
	if ([viewController.view respondsToSelector:@selector(tintColor)]) {
		viewController.view.tintColor = self.view.tintColor;
	}

	[self.navigationController presentViewController:viewController animated:YES completion:nil];
	_hasShown = YES;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)viewController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[viewController dismissViewControllerAnimated:YES completion:nil];
	if (self.navigationController.viewControllers.count == 1) {
		[self dismissViewControllerAnimated:NO completion:nil];
	} else {
		[self.realNavigationController popViewControllerAnimated:YES];
	}
}

@end
