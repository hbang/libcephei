#import "PSListController+HBTintAdditions.h"
#import "HBTintedTableCell.h"
#import "UINavigationItem+HBTintAdditions.h"
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIStatusBar.h>
#import <version.h>

BOOL translucentNavigationBar = NO;

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

- (void)viewDidLoad {
	%orig;

	// try and get appearance settings. this might be too early in most situations, but probably will
	// work for the initial view controler in the navigation stack, where for some reason
	// viewWillAppear: isn’t called on iOS 10
	[self _hb_getAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
	%orig;

	// if we didn’t get an appearance settings object before, try again now that we’re definitely on a
	// navigation controller
	[self _hb_getAppearance];

	UIColor *tintColor = nil;

	// if we have a tint color, grab it
	if (!tintColor && self.hb_appearanceSettings.tintColor) {
		tintColor = [self.hb_appearanceSettings.tintColor copy];
	}

	// set the table view background and cell separator colors
	if (self.hb_appearanceSettings.tableViewBackgroundColor) {
		self.table.backgroundColor = self.hb_appearanceSettings.tableViewBackgroundColor;
		self.table.backgroundView = nil;
	}

	if (self.hb_appearanceSettings.tableViewCellSeparatorColor) {
		self.table.separatorColor = self.hb_appearanceSettings.tableViewCellSeparatorColor;

		// it seems on old iOS you need to set the separator style to none for your custom separator
		// color to apply
		if (!IS_IOS_OR_NEWER(iOS_7_0)) {
			self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
		}
	}

	// if we have a translucent navigation bar, apply it
	translucentNavigationBar = self.hb_appearanceSettings.translucentNavigationBar;
	self._hb_realNavigationController.navigationBar.translucent = translucentNavigationBar;

	if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
		self.edgesForExtendedLayout = translucentNavigationBar ? UIRectEdgeAll : UIRectEdgeNone;
	}

	// if we have a tint color, apply it
	if ([self.view respondsToSelector:@selector(setTintColor:)]) {
		UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
		if (tintColor) {
			self.view.tintColor = tintColor;
			keyWindow.tintColor = tintColor;
		} else if (keyWindow.tintColor) {
			keyWindow.tintColor = nil;
		}
	}

	if (tintColor) {
		[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = tintColor;
	}

	// if we have a status bar tint color, apply it
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	UIColor *statusBarTintColor = self.hb_appearanceSettings.invertedNavigationBar ? [UIColor whiteColor] : self.hb_appearanceSettings.statusBarTintColor;
#pragma clang diagnostic pop

	if (statusBarTintColor && [UIStatusBar instancesRespondToSelector:@selector(setForegroundColor:)]) {
		UIStatusBar *statusBar = [UIApplication sharedApplication].statusBar;
		statusBar.foregroundColor = statusBarTintColor;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	%orig;

	// if we changed the status bar tint color, unset it
	if ([UIStatusBar instancesRespondToSelector:@selector(setForegroundColor:)]) {
		UIStatusBar *statusBar = [UIApplication sharedApplication].statusBar;

		if (statusBar.foregroundColor) {
			statusBar.foregroundColor = nil;
		}
	}

	// if the navigation bar wasn’t translucent, set it back
	if (!translucentNavigationBar) {
		self._hb_realNavigationController.navigationBar.translucent = IS_IOS_OR_NEWER(iOS_7_0);

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
		// if this view controller is definitely a PSListController and its appearance settings are
		// non-nil, grab that and break
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

		// hacky workaround to avoid ugly corners
		if (!IS_IOS_OR_NEWER(iOS_7_0)) {
			selectionView.layer.cornerRadius = 8.f;
		}

		cell.selectedBackgroundView = selectionView;
	}

	if (self.hb_appearanceSettings.tableViewCellTextColor) {
		if (![cell isKindOfClass:HBTintedTableCell.class]) {
			cell.textLabel.textColor = self.hb_appearanceSettings.tableViewCellTextColor;
		}

		cell.detailTextLabel.textColor = self.hb_appearanceSettings.tableViewCellTextColor;
	}

	if (self.hb_appearanceSettings.tableViewCellBackgroundColor) {
		cell.backgroundColor = self.hb_appearanceSettings.tableViewCellBackgroundColor;
	}

	return cell;
}

%end
