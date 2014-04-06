#import "HBListController.h"
#import "HBTintedTableCell.h"
#import <version.h>

@class HBRootListController;

#define IS_MODERN IS_IOS_OR_NEWER(iOS_7_0)

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

// TODO: figure out why none of these methods (that's right, none) are called when
// going back into Preferences after exiting.

- (void)viewDidLoad {
	// I'm not even gonna ask what this is about... https://www.youtube.com/watch?v=BkWl679wB1c
	[self cachedTintColor];
	[super viewDidLoad];
}

// If needed, and possible, runs through every view controller on the current navigation
// stack, pulling the Hashbang tintColor from the root Hashbang list view controller.
- (UIColor *)cachedTintColor {
	if (IS_MODERN) {
		if (!_cachedTintColor) {
			NSArray *viewControllers = self.navigationController.viewControllers;
			UIColor *tintColor = [self.class hb_tintColor];

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
		}

		return _cachedTintColor;
	}

	return nil;
}

- (void)viewWillAppear:(BOOL)animated {
	if (IS_MODERN) {
		self.view.tintColor = [self cachedTintColor];
		self.navigationController.navigationBar.tintColor = [self cachedTintColor];

		[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [self cachedTintColor];
		[UILabel appearanceWhenContainedIn:HBTintedTableCell.class, nil].textColor = [self cachedTintColor];
	}

	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (IS_MODERN) {
		self.view.tintColor = nil;
		self.navigationController.navigationBar.tintColor = nil;
	}
}

// Fixes weird iOS 7 glitch, a little neater than before, and ideally
// preventing crashes on iPads and older devices.
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
	[super tableView:arg1 didSelectRowAtIndexPath:arg2];
	[arg1 deselectRowAtIndexPath:arg2 animated:YES];
}

@end
