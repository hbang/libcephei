#import "HBRootListController.h"
#import "HBListController+Actions.h"
#import "../NSDictionary+HBAdditions.h"
#import <UIKit/UIImage+Private.h>
#import <version.h>
#import <objc/runtime.h>

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
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"heart"] style:UIBarButtonItemStylePlain target:self action:@selector(hb_shareTapped:)];
	}
}

#pragma mark - Callbacks

- (void)hb_shareTapped:(UIBarButtonItem *)sender {
	UIActivityViewController *viewController = [[UIActivityViewController alloc] initWithActivityItems:@[
		[self.class hb_shareText],
		[self.class hb_shareURL]
	] applicationActivities:nil];
	((UIPopoverPresentationController *)viewController.presentationController).barButtonItem = sender;
	[self presentViewController:viewController animated:YES completion:nil];
}

@end
