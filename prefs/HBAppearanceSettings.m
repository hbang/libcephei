#import "HBAppearanceSettings.h"
#import <version.h>

@implementation HBAppearanceSettings

#pragma mark - NSObject

- (instancetype)init {
	self = [super init];

	if (self) {
		// Set defaults. Everything else is either nil or NO, which is implicit.
		_showsNavigationBarShadow = YES;
	}

	return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
	HBAppearanceSettings *appearanceSettings = [[self.class alloc] init];
	appearanceSettings.tintColor = [self.tintColor copy];
	appearanceSettings.userInterfaceStyle = self.userInterfaceStyle;
	appearanceSettings.navigationBarTintColor = [self.navigationBarTintColor copy];
	appearanceSettings.navigationBarTitleColor = [self.navigationBarTitleColor copy];
	appearanceSettings.navigationBarBackgroundColor = [self.navigationBarBackgroundColor copy];
	appearanceSettings.statusBarStyle = self.statusBarStyle;
	appearanceSettings.showsNavigationBarShadow = self.showsNavigationBarShadow;
	appearanceSettings.largeTitleStyle = self.largeTitleStyle;
	appearanceSettings.tableViewBackgroundColor = [self.tableViewBackgroundColor copy];
	appearanceSettings.tableViewCellTextColor = [self.tableViewCellTextColor copy];
	appearanceSettings.tableViewCellBackgroundColor = [self.tableViewCellBackgroundColor copy];
	appearanceSettings.tableViewCellSeparatorColor = [self.tableViewCellSeparatorColor copy];
	appearanceSettings.tableViewCellSelectionColor = [self.tableViewCellSelectionColor copy];
	return appearanceSettings;
}

@end
