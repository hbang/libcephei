#import "HBRootListController.h"
#import "HBListController+Actions.h"
#import "../NSDictionary+HBAdditions.h"
#import <UIKit/UIImage+Private.h>
#import <version.h>

@interface HBListController ()

- (void)_hb_openURLInBrowser:(NSURL *)url;

@end

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
	if ([UIActivityViewController class] != nil) {
		// instantiate one with the share text and url as items
		UIActivityViewController *viewController = [[UIActivityViewController alloc] initWithActivityItems:@[
			[self.class hb_shareText],
			[self.class hb_shareURL]
		] applicationActivities:nil];

		if ([viewController respondsToSelector:@selector(presentationController)] && [viewController.presentationController respondsToSelector:@selector(barButtonItem)]) {
			((UIPopoverPresentationController *)viewController.presentationController).barButtonItem = sender;
		}

		[self presentViewController:viewController animated:YES completion:nil];
	} else {
		[self _hb_openURLInBrowser:[NSURL URLWithString:[@"https://twitter.com/intent/tweet?" stringByAppendingString:@{
			@"text": [NSString stringWithFormat:@"%@ %@", [self.class hb_shareText], [self.class hb_shareURL]]
		}.hb_queryString]]];
	}
}

@end
