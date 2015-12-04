#import "HBListController.h"
#import "HBTintedTableCell.h"
#import "UINavigationItem+HBTintAdditions.h"
#import <version.h>

UIStatusBarStyle previousStatusBarStyle = -1;
BOOL changedStatusBarStyle = NO;

@class HBRootListController;

@implementation HBListController

#pragma mark - Constants

+ (NSString *)hb_specifierPlist {
	return nil; // Totally makes sense.
}

+ (UIColor *)hb_tintColor {
	return nil;
}

+ (UIColor *)hb_navigationBarTintColor {
	return [self hb_tintColor];
}

+ (BOOL)hb_invertedNavigationBar {
	return NO;
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

- (instancetype)init {
	self = [super init];

	if (self) {
		UINavigationItem *navigationItem = self.navigationItem;
		navigationItem.hb_tintColor = [[self.class hb_tintColor] copy];
		navigationItem.hb_navigationBarBackgroundColor = [[self.class hb_invertedNavigationBar] ? [self.class hb_navigationBarTintColor] : nil copy];
		navigationItem.hb_navigationBarTintColor = [[self.class hb_invertedNavigationBar] ? [UIColor colorWithWhite:247.f / 255.f alpha:1] : [self.class hb_navigationBarTintColor] copy];
		navigationItem.hb_navigationBarTextColor = [[self.class hb_invertedNavigationBar] ? [UIColor whiteColor] : nil copy];
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	UIColor *tintColor = nil;

	// enumerate backwards over the navigation stack
	for (HBListController *viewController in self.navigationController.viewControllers.reverseObjectEnumerator) {
		// if we have a tint color, grab it and stop there
		if ([viewController.class respondsToSelector:@selector(hb_tintColor)] && [viewController.class hb_tintColor]) {
			tintColor = [viewController.class hb_tintColor];
			break;
		}
	}

	// if we have a tint color, apply it
	if (tintColor) {
		self.view.tintColor = tintColor;
		[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = tintColor;
	}

	BOOL changeStatusBar = NO;

	// enumerate the stack *again*
	for (HBListController *viewController in self.navigationController.viewControllers.reverseObjectEnumerator) {
		// if we have a YES hb_invertedNavigationBar value, grab it and stop there
		if ([viewController.class respondsToSelector:@selector(hb_invertedNavigationBar)] && [viewController.class hb_invertedNavigationBar]) {
			changeStatusBar = YES;
			break;
		}
	}

	// if the status bar is about to change to something custom, or we don’t
	// already know the previous status bar style, set it here
	if (changeStatusBar || previousStatusBarStyle == (UIStatusBarStyle)-1) {
		previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
	}

	// this will come in handy for later
	changedStatusBarStyle = changeStatusBar;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// set the status bar style accordingly
	if (changedStatusBarStyle) {
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (changedStatusBarStyle) {
		[UIApplication sharedApplication].statusBarStyle = previousStatusBarStyle;
	}
}

#pragma mark - Navigation controller quirks

/*
 The layout of Settings is weird on iOS 8. On iPhone, the actual navigation
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

#pragma mark - UITableViewDelegate

/*
 Fixes weird iOS 7 glitch, a little neater than before, and ideally preventing
 crashes on iPads and older devices.
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
