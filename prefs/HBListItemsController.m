#import "HBListItemsController.h"
#import "HBListController.h"
#import <version.h>

#define IS_MODERN IS_IOS_OR_NEWER(iOS_7_0)
;

@implementation HBListItemsController


#pragma mark - Constants

+ (UIColor *)hb_tintColor {
	return nil;
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (IS_MODERN) {
		UIColor *tintColor = [self.class hb_tintColor];
		NSArray *viewControllers = self.navigationController.viewControllers;

		if (!tintColor) {
			NSInteger i = viewControllers.count;

			while (--i) {
				if ([((NSObject *)viewControllers[i]).class respondsToSelector:@selector(hb_tintColor)] && [((HBListController *)viewControllers[i]).class hb_tintColor]) {
					tintColor = [((HBListController *)viewControllers[i]).class hb_tintColor];
					break;
				}
			}
		}

		self.view.tintColor = tintColor;
		self.navigationController.navigationBar.tintColor = tintColor;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (IS_MODERN) {
		self.view.tintColor = nil;
		self.navigationController.navigationBar.tintColor = nil;
	}
}

@end
