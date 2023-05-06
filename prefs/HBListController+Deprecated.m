#import "HBListController+Deprecated.h"
#import "HBAppearanceSettings.h"
#import <version.h>
#import <HBLog.h>

#if !ROOTLESS
@interface HBListController () {
	NSArray *__deprecatedAppearanceMethodsInUse;
}

@end

@implementation HBListController (Deprecated)

+ (UIColor *)hb_tintColor                    { return nil; }
+ (UIColor *)hb_navigationBarTintColor       { return [self hb_tintColor]; }
+ (BOOL)hb_invertedNavigationBar             { return NO; }
+ (UIColor *)hb_tableViewCellTextColor       { return nil; }
+ (UIColor *)hb_tableViewCellBackgroundColor { return nil; }
+ (UIColor *)hb_tableViewCellSeparatorColor  { return nil; }
+ (UIColor *)hb_tableViewCellSelectionColor  { return nil; }
+ (UIColor *)hb_tableViewBackgroundColor     { return nil; }
+ (BOOL)hb_translucentNavigationBar          { return YES; }

@end

@implementation HBListController (DeprecatedPrivate)

- (void)_handleDeprecatedAppearanceMethods {
	// If at least one deprecated method is in use, log a warning and make a HBAppearanceSettings
	// object using the values of the old methods.
	if (self._deprecatedAppearanceMethodsInUse.count > 0) {
		HBLogWarn(@"The deprecated HBListController appearance method(s) %@ are in use on %@. Please migrate to the new HBAppearanceSettings as described at https://hbang.github.io/libcephei/Classes/HBAppearanceSettings.html.", [self._deprecatedAppearanceMethodsInUse componentsJoinedByString:@", "], self.class);

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

- (NSArray *)_deprecatedAppearanceMethodsInUse {
	if (IS_IOS_OR_NEWER(iOS_10_0)) {
		return nil;
	}

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
		// Loop over deprecated appearance methods. If we get something different from the default, add
		// it to the list.
		NSMutableArray *methodsInUse = [NSMutableArray array];
		for (NSString *selector in AppearanceDeprecations) {
			SEL sel = NSSelectorFromString(selector);
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

@end
#endif
