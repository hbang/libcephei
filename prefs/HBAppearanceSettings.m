#import "HBAppearanceSettings.h"
#import <version.h>

@implementation HBAppearanceSettings

#pragma mark - NSObject

- (instancetype)init {
	self = [super init];

	if (self) {
		// set defaults. everything else is either nil or NO, which are set implicitly by objc
		_translucentNavigationBar = IS_IOS_OR_NEWER(iOS_7_0);
	}

	return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
	HBAppearanceSettings *appearanceSettings = [[self.class alloc] init];
	appearanceSettings.tintColor = [self.tintColor copy];
	appearanceSettings.navigationBarTintColor = [self.navigationBarTintColor copy];
	appearanceSettings.navigationBarTitleColor = [self.navigationBarTitleColor copy];
	appearanceSettings.navigationBarBackgroundColor = [self.navigationBarBackgroundColor copy];
	appearanceSettings.statusBarTintColor = [self.statusBarTintColor copy];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	appearanceSettings.invertedNavigationBar = self.invertedNavigationBar;
#pragma clang diagnostic pop
	appearanceSettings.translucentNavigationBar = self.translucentNavigationBar;
	appearanceSettings.tableViewBackgroundColor = [self.tableViewBackgroundColor copy];
	appearanceSettings.tableViewCellTextColor = [self.tableViewCellTextColor copy];
	appearanceSettings.tableViewCellBackgroundColor = [self.tableViewCellBackgroundColor copy];
	appearanceSettings.tableViewCellSeparatorColor = [self.tableViewCellSeparatorColor copy];
	appearanceSettings.tableViewCellSelectionColor = [self.tableViewCellSelectionColor copy];
	return appearanceSettings;
}

@end
