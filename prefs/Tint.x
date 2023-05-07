#import "HBAppearanceSettings.h"
#import "UINavigationItem+HBTintAdditions.h"
#import "../ui/UIColor+HBAdditions.h"
#import <UIKit/UINavigationBar+Private.h>
#import <version.h>

@interface UINavigationBar (HBTintAdditions)

@property (nonatomic, copy) HBAppearanceSettings *hb_appearanceSettings;

- (void)_hb_updateTintColorsAnimated:(BOOL)animated;

@end

%hook UINavigationBar

%property (nonatomic, copy) HBAppearanceSettings *hb_appearanceSettings;

#pragma mark - Tint color

- (void)_pushNavigationItem:(UINavigationItem *)item transition:(NSInteger)transition {
	%orig;
	[self _hb_updateTintColorsAnimated:transition != 0];
}

- (UINavigationItem *)_popNavigationItemWithTransition:(NSInteger)transition {
	UINavigationItem *item = %orig;
	[self _hb_updateTintColorsAnimated:transition != 0];
	return item;
}

- (UIColor *)_titleTextColor {
	return self.hb_appearanceSettings.navigationBarTitleColor ?: %orig;
}

%new - (void)_hb_updateTintColorsAnimated:(BOOL)animated {
	// Get the appearance settings from the top item on the stack. If it’s nil, use a standard
	// HBAppearanceSettings with the defaults.
	HBAppearanceSettings *appearanceSettings = ((UINavigationItem *)self.navigationItems.lastObject).hb_appearanceSettings ?: [[HBAppearanceSettings alloc] init];

	// Set it on ourselves in case other things need it
	self.hb_appearanceSettings = appearanceSettings;

	// Use the specified background color if one has been set, otherwise leave it unchanged (nil).
	self.barTintColor = appearanceSettings.navigationBarBackgroundColor;

	// Try the navigation bar tint color. If nil, use standard tint color (which could also be nil).
	self.tintColor = [appearanceSettings.navigationBarTintColor ?: appearanceSettings.tintColor hb_colorWithDarkInterfaceVariant];
}

- (void)_setItems:(NSArray *)items transition:(NSInteger)transition reset:(BOOL)reset resetOwningRelationship:(BOOL)resetOwningRelationship {
	%orig;
	[self _hb_updateTintColorsAnimated:transition != 0];
}

%end
