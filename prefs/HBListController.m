#import "HBListController.h"
#import "HBTintedTableCell.h"
#import <version.h>

@class HBRootListController;

#define IS_MODERN IS_IOS_OR_NEWER(iOS_7_0)
;

@interface HBListController () {
	UIColor *_cachedTintColor;
}

@end

@implementation HBListController

#pragma mark - Constants

+ (UIColor *)hb_tintColor {
	return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	if (IS_MODERN) {
		// https://www.youtube.com/watch?v=BkWl679wB1c
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

		_cachedTintColor = [tintColor copy];

		[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = tintColor;
		[UILabel appearanceWhenContainedIn:HBTintedTableCell.class, nil].textColor = tintColor;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	UITableView *tableView = [self respondsToSelector:@selector(table)] ? self.table : self.view;

	// fix weird bug where selected row doesn't deselect
	// thanks insanj <4
	[tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:YES];

	if (IS_MODERN) {
		self.view.tintColor = _cachedTintColor;
		self.navigationController.navigationBar.tintColor = _cachedTintColor;
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
