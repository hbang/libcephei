#import "HBListController.h"
#import "HBAppearanceSettings.h"
#import "PSListController+HBTintAdditions.h"
#import "UINavigationItem+HBTintAdditions.h"
#import <libprefs/prefs.h>
#import <version.h>

UIStatusBarStyle previousStatusBarStyle = -1;
BOOL changedStatusBarStyle = NO;
BOOL translucentNavigationBar = YES;

@implementation HBListController {
	UIColor *_tableViewCellTextColor;
	UIColor *_tableViewCellBackgroundColor;
	UIColor *_tableViewCellSelectionColor;
}

#pragma mark - Constants

+ (NSString *)hb_specifierPlist              { return nil; }

+ (UIColor *)hb_tintColor                    { return nil; }
+ (UIColor *)hb_navigationBarTintColor       { return [self hb_tintColor]; }
+ (BOOL)hb_invertedNavigationBar             { return NO; }
+ (UIColor *)hb_tableViewCellTextColor       { return nil; }
+ (UIColor *)hb_tableViewCellBackgroundColor { return nil; }
+ (UIColor *)hb_tableViewCellSeparatorColor  { return nil; }
+ (UIColor *)hb_tableViewCellSelectionColor  { return nil; }
+ (UIColor *)hb_tableViewBackgroundColor     { return nil; }
+ (BOOL)hb_translucentNavigationBar          { return YES; }

#pragma mark - Loading specifiers

- (void)_loadSpecifiersFromPlistIfNeeded {
	if (_specifiers || ![self.class hb_specifierPlist]) {
		return;
	}

	_specifiers = [self loadSpecifiersFromPlistName:[self.class hb_specifierPlist] target:self];
}

- (NSArray *)specifiers {
	[self _loadSpecifiersFromPlistIfNeeded];
	return _specifiers;
}

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(PSListController *)target bundle:(NSBundle *)bundle {
	// override the loading mechanism so we can add additional features
	NSArray *specifiers = [super loadSpecifiersFromPlistName:plistName target:target bundle:bundle];
	NSMutableArray *specifiersToRemove = [NSMutableArray array];

	for (PSSpecifier *specifier in specifiers) {
		// libprefs defines some filters we can take advantage of
		if (![PSSpecifier environmentPassesPreferenceLoaderFilter:specifier.properties[PLFilterKey]]) {
			[specifiersToRemove addObject:specifier];
		}
	}

	// if we have specifiers to remove
	if (specifiersToRemove.count > 0) {
		// make a mutable copy of the specifiers
		NSMutableArray *newSpecifiers = [specifiers mutableCopy];

		// remove all the filtered specifiers
		[newSpecifiers removeObjectsInArray:specifiersToRemove];

		// and assign it to specifiers again
		specifiers = newSpecifiers;
	}

	return specifiers;
}

#pragma mark - UIViewController

- (instancetype)init {
	self = [super init];

	if (self) {
		[self _warnAboutDeprecatedMethods];
		[self _getAppearance];
	}

	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	UIColor *tintColor = nil;

	BOOL changeStatusBar = NO;

	UIColor *tableViewCellSeparatorColor = nil;
	UIColor *tableViewBackgroundColor = nil;

	// enumerate backwards over the navigation stack
	for (HBListController *viewController in self.navigationController.viewControllers.reverseObjectEnumerator) {
		// if we have a tint color, grab it and stop there
		if (!tintColor && [viewController.class respondsToSelector:@selector(hb_tintColor)] && [viewController.class hb_tintColor]) {
			tintColor = [[viewController.class hb_tintColor] copy];
		}

		// if we have a hb_translucentNavigationBar value, grab it
		if ([viewController.class respondsToSelector:@selector(hb_translucentNavigationBar)] && ![viewController.class hb_translucentNavigationBar]) {
			translucentNavigationBar = NO;
		}

		// if we don’t already know that the status bar is going to change, and we
		// have a YES hb_invertedNavigationBar value, grab that
		if (!changeStatusBar && [viewController.class respondsToSelector:@selector(hb_invertedNavigationBar)] && [viewController.class hb_invertedNavigationBar]) {
			changeStatusBar = YES;
		}

		// ditto all the table view color methods
		if (!_tableViewCellTextColor && [viewController.class respondsToSelector:@selector(hb_tableViewCellTextColor)] && [viewController.class hb_tableViewCellTextColor]) {
			_tableViewCellTextColor = [[viewController.class hb_tableViewCellTextColor] copy];
		}

		if (!_tableViewCellBackgroundColor && [viewController.class respondsToSelector:@selector(hb_tableViewCellBackgroundColor)] && [viewController.class hb_tableViewCellBackgroundColor]) {
			_tableViewCellBackgroundColor = [[viewController.class hb_tableViewCellBackgroundColor] copy];
		}

		if (!_tableViewCellSelectionColor && [viewController.class respondsToSelector:@selector(hb_tableViewCellSelectionColor)] && [viewController.class hb_tableViewCellSelectionColor]) {
			_tableViewCellSelectionColor = [[viewController.class hb_tableViewCellSelectionColor] copy];
		}

		if ([viewController.class respondsToSelector:@selector(hb_tableViewCellSeparatorColor)] && [viewController.class hb_tableViewCellSeparatorColor]) {
			tableViewCellSeparatorColor = [[viewController.class hb_tableViewCellSeparatorColor] copy];
		}

		if ([viewController.class respondsToSelector:@selector(hb_tableViewBackgroundColor)] && [viewController.class hb_tableViewBackgroundColor]) {
			tableViewBackgroundColor = [[viewController.class hb_tableViewBackgroundColor] copy];
		}
	}

	if (tableViewCellSeparatorColor) {
		self.table.separatorColor = tableViewCellSeparatorColor;
	}

	if (tableViewBackgroundColor) {
		self.table.backgroundColor = tableViewBackgroundColor;
	}

	self.realNavigationController.navigationBar.translucent = translucentNavigationBar;
	self.edgesForExtendedLayout = translucentNavigationBar ? UIRectEdgeAll : UIRectEdgeNone;

	// if we have a tint color, apply it
	if (tintColor) {
		self.view.tintColor = tintColor;
		[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = tintColor;
	}

	// if the status bar is about to change to something custom, or we don’t
	// already know the previous status bar style, set it here
	previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;

	// set the status bar style accordingly
	if (changeStatusBar) {
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[UIApplication sharedApplication].statusBarStyle = previousStatusBarStyle;

	if (!translucentNavigationBar) {
		self.realNavigationController.navigationBar.translucent = YES;
		self.edgesForExtendedLayout = UIRectEdgeAll;
	}
}

#pragma mark - Appearance

- (NSArray *)_deprecatedAppearanceMethodsInUse {
	static NSArray *AppearanceDeprecations;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		AppearanceDeprecations = [@[
			@"hb_tintColor",
			@"hb_navigationBarTintColor",
			@"hb_invertedNavigationBar",
			@"hb_translucentNavigationBar",
			@"hb_tableViewBackgroundColor",
			@"hb_tableViewCellTextColor",
			@"hb_tableViewCellBackgroundColor",
			@"hb_tableViewCellSeparatorColor"
		] retain];
	});

	NSMutableArray *methodsInUse = [NSMutableArray array];

	// loop over deprecated appearance methods
	for (NSString *selector in AppearanceDeprecations) {
		SEL sel = NSSelectorFromString(selector);

		// if we get something different from the default, then add it to the list
		if ([self.class performSelector:sel] != [HBListController performSelector:sel]) {
			[methodsInUse addObject:selector];
		}
	}

	return methodsInUse;
}

- (void)_getAppearance {
	// if at least one deprecated method is in use
	if (self._deprecatedAppearanceMethodsInUse.count > 0) {
		// set up an HBAppearanceSettings using the values of the old methods
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = [self.class hb_tintColor];
		appearanceSettings.navigationBarTintColor = [self.class hb_navigationBarTintColor];
		appearanceSettings.invertedNavigationBar = [self.class hb_invertedNavigationBar];
		appearanceSettings.translucentNavigationBar = [self.class hb_translucentNavigationBar];
		appearanceSettings.tableViewBackgroundColor = [self.class hb_tableViewBackgroundColor];
		appearanceSettings.tableViewCellTextColor = [self.class hb_tableViewCellTextColor];
		appearanceSettings.tableViewCellBackgroundColor = [self.class hb_tableViewCellBackgroundColor];
		appearanceSettings.tableViewCellSeparatorColor = [self.class hb_tableViewCellSeparatorColor];
		self.hb_appearanceSettings = appearanceSettings;
	} else {
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
}

- (void)_warnAboutDeprecatedMethods {
	NSArray *methodsInUse = self._deprecatedAppearanceMethodsInUse;

	// if at least one appearance method is in use, log
	if (methodsInUse.count > 0) {
		HBLogWarn(@"The deprecated HBListController appearance method(s) %@ are in use on %@. Please migrate to the new HBAppearanceSettings as described at https://hbang.github.io/libcephei/Classes/HBAppearanceSettings.html.", [methodsInUse componentsJoinedByString:@", "], self.class);
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

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

@end
