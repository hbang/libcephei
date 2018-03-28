#import "HBListController.h"
#import "HBAppearanceSettings.h"
#import "HBLinkTableCell.h"
#import "HBSupportController+Private.h"
#import "PSListController+HBTintAdditions.h"
#import "UINavigationItem+HBTintAdditions.h"
#import <Preferences/PSSpecifier.h>
#import <TechSupport/TSPackage.h>

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

- (instancetype)init {
	self = [super init];

	if (self) {
		// when an HBPackageNameHeaderCell is instantiated, it grabs the package metadata via TSPackage.
		// the first time it’s called, +[PIDebianPackage initialize] is invoked, which implements a long
		// blocking operation (~200ms on iPhone 6s, definitely worse on older devices). this causes a
		// really noticeable momentary freeze, which we really don’t want. work around this by warming
		// PIDebianPackage on a background queue (with throttled I/O), reducing subsequent calls to a
		// more tolerable duration (~70ms).
#if !CEPHEI_EMBEDDED
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
				__unused TSPackage *package = [HBSupportController _packageForIdentifier:@"ws.hbang.common" orFile:nil];
			});
		});
#endif
	}

	return self;
}

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

- (NSMutableArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(PSListController *)target bundle:(NSBundle *)bundle {
	// override the loading mechanism so we can add additional features
	NSMutableArray *specifiers = [super loadSpecifiersFromPlistName:plistName target:target bundle:bundle];
	NSMutableArray *specifiersToRemove = [NSMutableArray array];

	for (PSSpecifier *specifier in specifiers) {
		// we provide a CF version filter here, originally by calling through to libprefs, but meh. it’s
		// simple enough i might as well provide it myself
		NSDictionary *filters = specifier.properties[@"pl_filter"];

		if (filters && filters[@"CoreFoundationVersion"]) {
			NSArray <NSNumber *> *versionFilter = filters[@"CoreFoundationVersion"];

			// array with 1 item means there’s only a minimum bounds. array with 2 items means there’s a
			// min and max bounds
			double min = versionFilter[0] ? ((NSNumber *)versionFilter[0]).doubleValue : DBL_MIN;
			double max = versionFilter.count > 1 && versionFilter[1] ? ((NSNumber *)versionFilter[1]).doubleValue : DBL_MAX;

			if (min < kCFCoreFoundationVersionNumber || max >= kCFCoreFoundationVersionNumber) {
				[specifiersToRemove addObject:specifier];
			}
		}

		// grab the cell class
		Class cellClass = specifier.properties[PSCellClassKey];

		// if it’s HBLinkTableCell, override the type and action to our own
		if ([cellClass isSubclassOfClass:HBLinkTableCell.class]) {
			specifier.cellType = PSLinkCell;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
			specifier.buttonAction = @selector(hb_openURL:);
#pragma clang diagnostic pop
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		appearanceSettings.tintColor = [self.class hb_tintColor];
		appearanceSettings.navigationBarTintColor = [self.class hb_navigationBarTintColor];
		appearanceSettings.invertedNavigationBar = [self.class hb_invertedNavigationBar];
		appearanceSettings.translucentNavigationBar = [self.class hb_translucentNavigationBar];
		appearanceSettings.tableViewBackgroundColor = [self.class hb_tableViewBackgroundColor];
		appearanceSettings.tableViewCellTextColor = [self.class hb_tableViewCellTextColor];
		appearanceSettings.tableViewCellBackgroundColor = [self.class hb_tableViewCellBackgroundColor];
		appearanceSettings.tableViewCellSeparatorColor = [self.class hb_tableViewCellSeparatorColor];
#pragma clang diagnostic pop
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
