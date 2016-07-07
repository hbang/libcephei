#import "PSListController+HBTintAdditions.h"
#import "UINavigationItem+HBTintAdditions.h"

UIStatusBarStyle previousStatusBarStyle = -1;
BOOL changedStatusBarStyle = NO;
BOOL translucentNavigationBar = YES;

@interface PSListController ()

@property (nonatomic, retain) HBAppearanceSettings *_hb_internalAppearanceSettings;
@property (nonatomic, retain) UIColor *_hb_tableViewCellTextColor;
@property (nonatomic, retain) UIColor *_hb_tableViewCellBackgroundColor;
@property (nonatomic, retain) UIColor *_hb_tableViewCellSelectionColor;

- (UINavigationController *)_hb_realNavigationController;
- (void)_hb_getAppearance;

@end

@implementation PSListController (HBTintAdditions)

@dynamic hb_appearanceSettings;

@end

%hook PSListController

%property (nonatomic, retain) HBAppearanceSettings *_hb_internalAppearanceSettings;
%property (nonatomic, retain) UIColor *_hb_tableViewCellTextColor;
%property (nonatomic, retain) UIColor *_hb_tableViewCellBackgroundColor;
%property (nonatomic, retain) UIColor *_hb_tableViewCellSelectionColor;

#pragma mark - Getter/setter

%new - (HBAppearanceSettings *)hb_appearanceSettings {
	return self._hb_internalAppearanceSettings;
}

%new - (void)hb_setAppearanceSettings:(HBAppearanceSettings *)appearanceSettings {
	// if appearanceSettings is nil, instantiate a generic appearance object
	if (!appearanceSettings) {
		appearanceSettings = [[HBAppearanceSettings alloc] init];
	}

	// set the internal property
	self._hb_internalAppearanceSettings = [appearanceSettings copy];

	// the navigation item also needs access to the appearance settings
	self.navigationItem.hb_appearanceSettings = self._hb_internalAppearanceSettings;
}

#pragma mark - UIViewController

- (instancetype)init {
	self = %orig;

	if (self) {
		[self _hb_getAppearance];
	}

	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	%orig;

	// if we didn’t get an appearance settings object before, try again now that
	// we’re definitely on a navigation controller
	[self _hb_getAppearance];

	UIColor *tintColor = nil;
	BOOL changeStatusBar = NO;

	// if we have a tint color, grab it
	if (!tintColor && self.hb_appearanceSettings.tintColor) {
		tintColor = [self.hb_appearanceSettings.tintColor copy];
	}

	// if we have a translucentNavigationBar value, grab it
	if (!self.hb_appearanceSettings.translucentNavigationBar) {
		translucentNavigationBar = NO;
	}

	// if we have a YES invertedNavigationBar value, remember that
	if (self.hb_appearanceSettings.invertedNavigationBar) {
		changeStatusBar = YES;
	}

	// set the table view background and cell separator colors
	if (self.hb_appearanceSettings.tableViewBackgroundColor) {
		self.table.backgroundColor = self.hb_appearanceSettings.tableViewBackgroundColor;
	}

	if (self.hb_appearanceSettings.tableViewCellSeparatorColor) {
		self.table.separatorColor = self.hb_appearanceSettings.tableViewCellSeparatorColor;
	}

	// if we have a translucent navigation bar, apply it
	self._hb_realNavigationController.navigationBar.translucent = translucentNavigationBar;

	if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
		self.edgesForExtendedLayout = translucentNavigationBar ? UIRectEdgeAll : UIRectEdgeNone;
	}

	// if we have a tint color, apply it
	if (tintColor) {
		if ([self.view respondsToSelector:@selector(setTintColor:)]) {
			self.view.tintColor = tintColor;
		}
		
		[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = tintColor;
	}

	// if the status bar is about to change to something custom, or we don’t
	// already know the previous status bar style, set it here
	if ((changeStatusBar && !changedStatusBarStyle) || previousStatusBarStyle == (UIStatusBarStyle)-1) {
		previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
	}

	// set the status bar style accordingly
	if (changeStatusBar) {
		changedStatusBarStyle = YES;
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	%orig;

	// if we have a cached previous status bar style, and the style has changed,
	// set it back
	if (changedStatusBarStyle && previousStatusBarStyle != (UIStatusBarStyle)-1) {
		changedStatusBarStyle = NO;
		[UIApplication sharedApplication].statusBarStyle = previousStatusBarStyle;
	}

	// if the navigation bar wasn’t translucent, set it back
	if (!translucentNavigationBar) {
		self._hb_realNavigationController.navigationBar.translucent = YES;

		if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
			self.edgesForExtendedLayout = UIRectEdgeAll;
		}
	}
}

#pragma mark - Navigation controller quirks

// The layout of Settings is weird on iOS 8. On iPhone, the actual navigation
// controller is the parent of self.navigationController. On iPad, it remains
// how it's always been.
%new - (UINavigationController *)_hb_realNavigationController {
	UINavigationController *navigationController = self.navigationController;

	while (navigationController.navigationController) {
		navigationController = navigationController.navigationController;
	}

	return navigationController;
}

#pragma mark - Appearance

%new - (void)_hb_getAppearance {
	// if we already have appearance settings, we don’t need to worry about this
	if (self.hb_appearanceSettings) {
		return;
	}

	// enumerate backwards over the navigation stack
	for (PSListController *viewController in self.navigationController.viewControllers.reverseObjectEnumerator) {
		// if this view controller is definitely a PSListController and its
		// appearance settings are non-nil, grab that and break
		if ([viewController isKindOfClass:PSListController.class] && viewController.hb_appearanceSettings) {
			self.hb_appearanceSettings = viewController.hb_appearanceSettings;
			break;
		}
	}
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = %orig;

	if (self.hb_appearanceSettings.tableViewCellSelectionColor) {
		UIView *selectionView = [[UIView alloc] init];
		selectionView.backgroundColor = self.hb_appearanceSettings.tableViewCellSelectionColor;
		cell.selectedBackgroundView = selectionView;
	}

	if (self.hb_appearanceSettings.tableViewCellTextColor) {
		cell.textLabel.textColor = self.hb_appearanceSettings.tableViewCellTextColor;
	}

	if (self.hb_appearanceSettings.tableViewCellBackgroundColor) {
		cell.backgroundColor = self.hb_appearanceSettings.tableViewCellBackgroundColor;
	}

	return cell;
}

%end
