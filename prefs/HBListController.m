#import "HBListController.h"
#import "HBAppearanceSettings.h"
#import "HBLinkTableCell.h"
#import "PSListController+HBTintAdditions.h"
#import "UINavigationItem+HBTintAdditions.h"
#import <Preferences/PSSpecifier.h>
#import <libprefs/prefs.h>

@interface PSListController ()

- (UINavigationController *)_hb_realNavigationController;
- (void)_hb_getAppearance;

@end

@implementation HBListController {
	NSArray *__deprecatedAppearanceMethodsInUse;
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

		// grab the cell class
		Class cellClass = specifier.properties[PSCellClassKey];

		// if it’s HBLinkTableCell
		if ([cellClass isSubclassOfClass:HBLinkTableCell.class]) {
			// override the type and action to our own
			specifier.cellType = PSLinkCell;
			specifier.buttonAction = @selector(hb_openURL:);
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

#pragma mark - Appearance

- (NSArray *)_deprecatedAppearanceMethodsInUse {
	static NSArray *AppearanceDeprecations;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		AppearanceDeprecations = @[
			@"hb_tintColor",
			@"hb_navigationBarTintColor",
			@"hb_invertedNavigationBar",
			@"hb_translucentNavigationBar",
			@"hb_tableViewBackgroundColor",
			@"hb_tableViewCellTextColor",
			@"hb_tableViewCellBackgroundColor",
			@"hb_tableViewCellSeparatorColor"
		];
	});

	if (!__deprecatedAppearanceMethodsInUse) {
		NSMutableArray *methodsInUse = [NSMutableArray array];

		// loop over deprecated appearance methods
		for (NSString *selector in AppearanceDeprecations) {
			SEL sel = NSSelectorFromString(selector);

			// if we get something different from the default, then add it to the list
			// TODO: we probably should be doing it right™ with methodForSelector:,
			// but that broke something and i don’t really have the time to look into
			// it just yet – http://stackoverflow.com/a/20058585/709376
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			if ([self.class performSelector:sel] != [HBListController performSelector:sel]) {
#pragma clang diagnostic pop
				[methodsInUse addObject:selector];
			}
		}

		__deprecatedAppearanceMethodsInUse = [methodsInUse copy];
	}

	return __deprecatedAppearanceMethodsInUse;
}

- (void)_hb_getAppearance {
	[super _hb_getAppearance];

	// if at least one deprecated method is in use
	if (self._deprecatedAppearanceMethodsInUse.count > 0) {
		[self _warnAboutDeprecatedMethods];

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

- (UINavigationController *)realNavigationController {
	return [super _hb_realNavigationController];
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// fixes weird iOS 7 glitch, a little neater than before, and ideally preventing
	// crashes on iPads and older devices.
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
