#import "HBAppearanceSettings.h"

@implementation HBAppearanceSettings

#pragma mark - NSObject

- (instancetype)init {
	self = [super init];

	if (self) {
		// set defaults. everything else is either nil or NO, which are set
		// implicitly by objc
		_translucentNavigationBar = YES;
	}

	return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
	HBAppearanceSettings *appearanceSettings = [[self.class alloc] init];
	appearanceSettings.tintColor = [self.tintColor copy];
	appearanceSettings.navigationBarTintColor = [self.navigationBarTintColor copy];
	appearanceSettings.invertedNavigationBar = self.invertedNavigationBar;
	appearanceSettings.translucentNavigationBar = self.translucentNavigationBar;
	appearanceSettings.tableViewBackgroundColor = [self.tableViewBackgroundColor copy];
	appearanceSettings.tableViewCellTextColor = [self.tableViewCellTextColor copy];
	appearanceSettings.tableViewCellBackgroundColor = [self.tableViewCellBackgroundColor copy];
	appearanceSettings.tableViewCellSeparatorColor = [self.tableViewCellSeparatorColor copy];
	appearanceSettings.tableViewCellSelectionColor = [self.tableViewCellSelectionColor copy];
	return appearanceSettings;
}

#pragma mark - Memory management

- (void)dealloc {
	[_tintColor release];
	[_navigationBarTintColor release];
	[_tableViewBackgroundColor release];
	[_tableViewCellTextColor release];
	[_tableViewCellBackgroundColor release];
	[_tableViewCellSeparatorColor release];
	[_tableViewCellSelectionColor release];

	[super dealloc];
}

@end
