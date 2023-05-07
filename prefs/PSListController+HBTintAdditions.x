#import "PSListController+HBTintAdditions.h"
#import "HBRootListController.h"
#import "HBTintedTableCell.h"
#import "UINavigationItem+HBTintAdditions.h"
#import "../ui/UIColor+HBAdditions.h"
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIStatusBar.h>
#import <version.h>

@interface PSListController ()

@property (nonatomic, retain) HBAppearanceSettings *_hb_internalAppearanceSettings;
@property (nonatomic, retain) UIColor *_hb_tableViewCellTextColor;
@property (nonatomic, retain) UIColor *_hb_tableViewCellBackgroundColor;
@property (nonatomic, retain) UIColor *_hb_tableViewCellSelectionColor;

- (UINavigationBarAppearance *)_hb_configureNavigationBarAppearance:(UINavigationBarAppearance *)appearance API_AVAILABLE(ios(13.0));
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
	// If appearanceSettings is nil, instantiate a generic appearance object
	if (appearanceSettings == nil) {
		appearanceSettings = [[HBAppearanceSettings alloc] init];
	}
	self._hb_internalAppearanceSettings = [appearanceSettings copy];
	self.navigationItem.hb_appearanceSettings = self._hb_internalAppearanceSettings;

	// Set iOS 11.0+ large title mode.
	self._hb_realNavigationController.navigationBar.prefersLargeTitles = YES;
	UINavigationItemLargeTitleDisplayMode largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
	switch (self.hb_appearanceSettings.largeTitleStyle) {
		case HBAppearanceSettingsLargeTitleStyleRootOnly:
			largeTitleDisplayMode = [self isKindOfClass:HBRootListController.class] ? UINavigationItemLargeTitleDisplayModeAlways : UINavigationItemLargeTitleDisplayModeNever;
			break;

		case HBAppearanceSettingsLargeTitleStyleAlways:
			largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
			break;

		case HBAppearanceSettingsLargeTitleStyleNever:
			largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
			break;
	}
	self.navigationItem.largeTitleDisplayMode = largeTitleDisplayMode;

	// Set iOS 13.0+ navigation bar appearance.
	if (self.navigationItem.scrollEdgeAppearance == nil) {
		UINavigationBarAppearance *scrollEdgeAppearance = [[%c(UINavigationBarAppearance) alloc] init];
		[scrollEdgeAppearance configureWithTransparentBackground];
		self.navigationItem.scrollEdgeAppearance = scrollEdgeAppearance;
	}
	self.navigationItem.standardAppearance = [self _hb_configureNavigationBarAppearance:self.navigationItem.standardAppearance];
	self.navigationItem.scrollEdgeAppearance = [self _hb_configureNavigationBarAppearance:self.navigationItem.scrollEdgeAppearance];
	self.navigationItem.compactAppearance = [self _hb_configureNavigationBarAppearance:self.navigationItem.compactAppearance];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	%orig;

	// Try and get appearance settings. This might be too early in most situations, but probably will
	// work for the initial view controler in the navigation stack, where for some reason
	// viewWillAppear: isn’t called on iOS 10
	[self _hb_getAppearance];
}

%new - (id)_hb_configureNavigationBarAppearance:(id)appearance {
	UIColor *titleColor = self.hb_appearanceSettings.navigationBarTitleColor;
	UIColor *backgroundColor = self.hb_appearanceSettings.navigationBarBackgroundColor;

	UINavigationBarAppearance *newAppearance;
	if (appearance == nil) {
		newAppearance = [[%c(UINavigationBarAppearance) alloc] init];
		[newAppearance configureWithDefaultBackground];
	} else {
		newAppearance = [[%c(UINavigationBarAppearance) alloc] initWithBarAppearance:appearance];
	}
	NSMutableDictionary <NSAttributedStringKey, id> *titleTextAttributes = [newAppearance.titleTextAttributes mutableCopy] ?: [NSMutableDictionary dictionary];
	NSMutableDictionary <NSAttributedStringKey, id> *largeTitleTextAttributes = [newAppearance.largeTitleTextAttributes mutableCopy] ?: [NSMutableDictionary dictionary];
	if (titleColor == nil) {
		[titleTextAttributes removeObjectForKey:NSForegroundColorAttributeName];
		[largeTitleTextAttributes removeObjectForKey:NSForegroundColorAttributeName];
	} else {
		titleTextAttributes[NSForegroundColorAttributeName] = titleColor;
		largeTitleTextAttributes[NSForegroundColorAttributeName] = titleColor;
	}
	newAppearance.backgroundColor = backgroundColor;
	newAppearance.titleTextAttributes = titleTextAttributes;
	newAppearance.largeTitleTextAttributes = largeTitleTextAttributes;
	if (!self.hb_appearanceSettings.showsNavigationBarShadow) {
		newAppearance.shadowColor = nil;
	}
	return newAppearance;
}

- (void)viewWillAppear:(BOOL)animated {
	%orig;

	// If we didn’t get an appearance settings object before, try again now that we’re definitely on a
	// navigation controller.
	[self _hb_getAppearance];

	UIColor *tintColor = [[self.hb_appearanceSettings.tintColor hb_colorWithDarkInterfaceVariant] copy];

	// Set the table view background and cell separator colors
	if (self.hb_appearanceSettings.tableViewBackgroundColor) {
		self.table.backgroundColor = self.hb_appearanceSettings.tableViewBackgroundColor;
		self.table.backgroundView = nil;
	}

	if (self.hb_appearanceSettings.tableViewCellSeparatorColor) {
		self.table.separatorColor = self.hb_appearanceSettings.tableViewCellSeparatorColor;
	}

	// If we have a tint color, apply it
	UIWindow *window = self.view.window;
	if (tintColor) {
		self.view.tintColor = tintColor;
		window.tintColor = tintColor;
	} else if (window.tintColor) {
		window.tintColor = nil;
	}

	if (tintColor) {
		[UISwitch appearanceWhenContainedInInstancesOfClasses:@[[self class]]].onTintColor = tintColor;
	}

	// Set user interface style
	[self setNeedsStatusBarAppearanceUpdate];
	self.overrideUserInterfaceStyle = self.hb_appearanceSettings.userInterfaceStyle;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	if (self.hb_appearanceSettings.statusBarStyle != UIStatusBarStyleDefault) {
		return self.hb_appearanceSettings.statusBarStyle;
	}
	return %orig;
}

#pragma mark - Navigation controller quirks

// The layout of Settings is weird on iOS 8. On iPhone, the actual navigation controller is the
// parent of self.navigationController. On iPad, it remains how it’s always been.
%new - (UINavigationController *)_hb_realNavigationController {
	UINavigationController *navigationController = self.navigationController;
	return navigationController.navigationController ?: navigationController;
}

#pragma mark - Appearance

%new - (void)_hb_getAppearance {
	// If we already have appearance settings, we don’t need to worry about this
	if (self.hb_appearanceSettings != nil) {
		return;
	}

	// Enumerate backwards over the navigation stack to find the closest view controller that has set
	// an appearance settings object. Copy that for ourselves.
	for (PSListController *viewController in self.navigationController.viewControllers.reverseObjectEnumerator) {
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


%hook UINavigationController

- (UIStatusBarStyle)preferredStatusBarStyle {
	return self.viewControllers.lastObject.preferredStatusBarStyle ?: %orig;
}

%end
