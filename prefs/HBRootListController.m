#import "HBRootListController.h"
#import "../NSString+HBAdditions.h"
#import <Twitter/Twitter.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>
#include <objc/runtime.h>

static Class $UIActivityViewController, $TWTweetComposeViewController;

@implementation HBRootListController

+ (void)initialize {
	[super initialize];

	$UIActivityViewController = objc_getClass("UIActivityViewController");
}

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
		if (IS_IOS_OR_NEWER(iOS_7_0)) {
			UIImage *icon = nil;
			if (@available(iOS 13.0, *)) {
				if (IS_IOS_OR_NEWER(iOS_13_0)) {
					icon = [UIImage systemImageNamed:@"heart"];
				}
			}
			if (icon == nil) {
				icon = [UIImage imageNamed:@"heart" inBundle:cepheiGlobalBundle];
			}
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStylePlain target:self action:@selector(hb_shareTapped:)];
		} else {
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(hb_shareTapped:)];
		}
	}
}

#pragma mark - Callbacks

- (void)hb_shareTapped:(UIBarButtonItem *)sender {
	// if we have UIActivityViewController (ios 6+)
	if ($UIActivityViewController) {
		// instantiate one with the share text and url as items
		UIActivityViewController *viewController = [[$UIActivityViewController alloc] initWithActivityItems:@[
			[self.class hb_shareText],
			[self.class hb_shareURL]
		] applicationActivities:nil];

		if ([viewController respondsToSelector:@selector(presentationController)] && [viewController.presentationController respondsToSelector:@selector(barButtonItem)]) {
			((UIPopoverPresentationController *)viewController.presentationController).barButtonItem = sender;
		}

		[self.navigationController presentViewController:viewController animated:YES completion:nil];
	} else {
		// for ios 5: lazy load Twitter.framework
		[[NSBundle bundleWithPath:@"/System/Library/Frameworks/Twitter.framework"] load];

		if (!$TWTweetComposeViewController) {
			$TWTweetComposeViewController = objc_getClass("TWTweetComposeViewController");
		}

		// if it loaded and we have a twitter account, instantiate a tweet composer. otherwise, just
		// open the twitter website
		if ($TWTweetComposeViewController && [$TWTweetComposeViewController canSendTweet]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
			TWTweetComposeViewController *viewController = [[$TWTweetComposeViewController alloc] init];
#pragma clang diagnostic pop
			viewController.initialText = [self.class hb_shareText];
			[viewController addURL:[self.class hb_shareURL]];
			[self.navigationController presentViewController:viewController animated:YES completion:nil];
		} else {
#ifdef THEOS
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@%%20%@", [self.class hb_shareText].hb_stringByEncodingQueryPercentEscapes, [self.class hb_shareURL].absoluteString.hb_stringByEncodingQueryPercentEscapes]]];
#endif
		}
	}
}

@end
