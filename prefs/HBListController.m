#import "HBListController.h"
#import "HBTintedTableCell.h"
#import <version.h>

@class HBRootListController;

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
	// yeah i don't even know myself ~kirb
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
				NSUInteger count = viewControllers.count;

				for (NSUInteger i = 2; i <= count; i++) {
					HBListController *viewController = viewControllers[count - i];

					if ([viewController.class respondsToSelector:@selector(hb_tintColor)] && [viewController.class hb_tintColor]) {
						tintColor = [viewController.class hb_tintColor];
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
	[super viewWillAppear:animated];

	if (IS_MODERN) {
		self.view.tintColor = [self cachedTintColor];

		if (IS_MOST_MODERN) {
			self.navigationController.navigationController.navigationBar.tintColor = [self cachedTintColor];
		}

		else {
			self.navigationController.navigationBar.tintColor = [self cachedTintColor];
		}

		[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [self cachedTintColor];
		[UILabel appearanceWhenContainedIn:HBTintedTableCell.class, nil].textColor = [self cachedTintColor];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (IS_MODERN) {
		self.view.tintColor = nil;

		if (IS_MOST_MODERN) {
			self.navigationController.navigationController.navigationBar.tintColor = nil;
		}

		else {
			self.navigationController.navigationBar.tintColor = nil;
		}

		[UILabel appearanceWhenContainedIn:HBTintedTableCell.class, nil].textColor = nil;
	}
}

#pragma mark - PSViewController

- (BOOL)canBeShownFromSuspendedState {
	return NO;
}

// Fixes weird iOS 7 glitch, a little neater than before, and ideally
// preventing crashes on iPads and older devices.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
