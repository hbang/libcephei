#import "HBRootListController.h"
#import <Twitter/Twitter.h>
#import <UIKit/UIImage+Private.h>

@implementation HBRootListController

#pragma mark - Constants

+ (NSString *)hb_shareText {
	return nil;
}

+ (NSURL *)hb_shareURL {
	return nil;
}

#pragma mark - UIViewController

- (void)loadView {
	[super loadView];

	if ([self.class hb_shareText] && [self.class hb_shareURL]) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"heart" inBundle:globalBundle] style:UIBarButtonItemStylePlain target:self action:@selector(hb_shareTapped:)];
	}
}

#pragma mark - Callbacks

- (void)hb_shareTapped:(UIBarButtonItem *)sender {
	if (%c(UIActivityViewController)) {
		UIActivityViewController *viewController = [[UIActivityViewController alloc] initWithActivityItems:@[ [self.class hb_shareText], [self.class hb_shareURL] ] applicationActivities:nil];

		if ([viewController respondsToSelector:@selector(presentationController)] && [viewController.presentationController respondsToSelector:@selector(barButtonItem)]) {
			((UIPopoverPresentationController *)viewController.presentationController).barButtonItem = sender;
		}

		[self.navigationController presentViewController:viewController animated:YES completion:nil];
	} else if ([TWTweetComposeViewController canSendTweet]) {
		TWTweetComposeViewController *viewController = [[TWTweetComposeViewController alloc] init];
		viewController.initialText = [self.class hb_shareText];
		[viewController addURL:[self.class hb_shareURL]];
		[self.navigationController presentViewController:viewController animated:YES completion:nil];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@%%20%@", URL_ENCODE([self.class hb_shareText]), URL_ENCODE([self.class hb_shareURL].absoluteString)]]];
	}
}

@end
