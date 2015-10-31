#import "HBListController.h"
#import "HBTintedTableCell.h"
#import <version.h>

@class HBRootListController;

@interface HBListController () {
	UIColor *_cachedTintColor;

	BOOL _invertedColors;

	UIStatusBarStyle _statusBarStyle;
	UIBarStyle _navigationBarStyle;
}

@end

@implementation HBListController

#pragma mark - Constants

+ (UIColor *)hb_tintColor {
	return nil;
}

+ (BOOL)hb_invertedColors {
	return NO;
}

+ (NSString *)hb_specifierPlist {
	return nil; // Totally makes sense.
}

#pragma mark - Loading specifiers

- (void)_loadSpecifiersFromPlistIfNeeded {
	if (_specifiers || ![self.class hb_specifierPlist]) {
		return;
	}

	_specifiers = [[self loadSpecifiersFromPlistName:[self.class hb_specifierPlist] target:self] retain];
}

- (NSArray *)specifiers {
	[self _loadSpecifiersFromPlistIfNeeded];
	return _specifiers;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	// I'm not even gonna ask what this is about... https://www.youtube.com/watch?v=BkWl679wB1c
	// yeah i don't even know myself ~kirb
	[self cachedTintColor];
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (IS_MODERN) {
		self.view.tintColor = [self.class hb_invertedColors] ? self.realNavigationController.navigationBar.barTintColor : [self cachedTintColor];
		self.realNavigationController.navigationBar.tintColor = [self.class hb_invertedColors] ? (self.realNavigationController.navigationBar.barTintColor ?: [UIColor colorWithRed:(247/255.0) green:(247/255.0) blue:(247/255.0) alpha:1]) : [self cachedTintColor];
		self.realNavigationController.navigationBar.barTintColor = [self.class hb_invertedColors] ? [self cachedTintColor] : self.realNavigationController.navigationBar.barTintColor;

		[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [self cachedTintColor];
		[UILabel appearanceWhenContainedIn:HBTintedTableCell.class, nil].textColor = [self cachedTintColor];

		if ([self.class hb_invertedColors]) {
			_statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
			_navigationBarStyle = self.realNavigationController.navigationBar.barStyle;
			self.realNavigationController.navigationBar.barStyle = UIBarStyleBlack;
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (IS_MODERN) {
		self.view.tintColor = nil;
		self.realNavigationController.navigationBar.tintColor = nil;
		self.realNavigationController.navigationBar.barTintColor = nil;

		[[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle];
		self.realNavigationController.navigationBar.barStyle = _navigationBarStyle;

		[UILabel appearanceWhenContainedIn:HBTintedTableCell.class, nil].textColor = nil;
	}
}

#pragma mark - Navigation controller quirks

/*
 The layout of Settings is weird on iOS 8. On iPhone, the actual navigatioon
 controller is the parent of self.navigationController. On iPad, it remains
 how it's always been.
*/
- (UINavigationController *)realNavigationController {
	UINavigationController *navigationController = self.navigationController;

	while (navigationController.navigationController) {
		navigationController = navigationController.navigationController;
	}

	return navigationController;
}

#pragma mark - Tint color

/*
 If needed, and possible, runs through every view controller on the current
 navigation stack, pulling the libcephei tintColor from the previous
 HBListController.
*/
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

#pragma mark - PSListController

/*
 this prevents specifiers from being lost if the app is closed and
 re-opened
*/
- (BOOL)canBeShownFromSuspendedState {
	return NO;
}

#pragma mark - UITableViewDelegate

/*
 Fixes weird iOS 7 glitch, a little neater than before, and ideally
 preventing crashes on iPads and older devices.
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
