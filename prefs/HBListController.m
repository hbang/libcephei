#import "HBListController.h"
#import "HBTintedTableCell.h"
#import "UINavigationItem+HBTintAdditions.h"
#import <version.h>

UIStatusBarStyle statusBarStyle;

@class HBRootListController;

@implementation HBListController

#pragma mark - Constants

+ (NSString *)hb_specifierPlist {
	return nil; // Totally makes sense.
}

+ (UIColor *)hb_tintColor {
	return nil;
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
		navigationItem.hb_navigationBarBackgroundColor = [[self.class hb_invertedNavigationBar] ? [self.class hb_tintColor] : nil copy];
		navigationItem.hb_navigationBarTintColor = [[self.class hb_invertedNavigationBar] ? [UIColor colorWithWhite:247.f / 255.f alpha:1] : [self.class hb_tintColor] copy];
		navigationItem.hb_navigationBarTextColor = [[self.class hb_invertedNavigationBar] ? [UIColor whiteColor] : nil copy];
	}

	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	// I'm not even gonna ask what this is about... https://www.youtube.com/watch?v=BkWl679wB1c
	// yeah i don't even know myself ~kirb

	[super viewWillAppear:animated];

	for (HBListController *viewController in self.navigationController.viewControllers.reverseObjectEnumerator) {
		if ([viewController.class respondsToSelector:@selector(hb_tintColor)] && [viewController.class hb_tintColor]) {
			self.view.tintColor = [viewController.class hb_tintColor];
			break;
		}
	}

	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = self.view.tintColor;

	if ([self.class hb_invertedNavigationBar]) {
		statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	}

}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	if ([self.class hb_invertedNavigationBar]) {
		[[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle];
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
