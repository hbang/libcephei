#import "HBAppearanceSettings.h"
#import "UINavigationItem+HBTintAdditions.h"
#import <UIKit/UINavigationBar+Private.h>
#import <version.h>

@interface UINavigationBar (HBTintAdditions)

@property (nonatomic, copy) HBAppearanceSettings *hb_appearanceSettings;

- (void)_hb_updateTintColorsAnimated:(BOOL)animated;

@end

BOOL animateBarTintColor = NO;

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

%group JonyIve
- (void)_setItems:(NSArray *)items transition:(NSInteger)transition {
	%orig;
	[self _hb_updateTintColorsAnimated:transition != 0];
}
%end

%group CraigFederighi
- (void)_setItems:(NSArray *)items transition:(NSInteger)transition reset:(BOOL)reset {
	%orig;
	[self _hb_updateTintColorsAnimated:transition != 0];
}
%end

%group EddyCue
- (void)_setItems:(NSArray *)items transition:(NSInteger)transition reset:(BOOL)reset resetOwningRelationship:(BOOL)resetOwningRelationship {
	%orig;
	[self _hb_updateTintColorsAnimated:transition != 0];
}
%end

- (UIColor *)_titleTextColor {
	// if the navigation bar is inverted then we use white, otherwise fallback to
	// orig
	return self.hb_appearanceSettings.invertedNavigationBar ? [UIColor whiteColor] : %orig;
}

%new - (void)_hb_updateTintColorsAnimated:(BOOL)animated {
	// get the appearance settings from the top item on the stack. if it’s nil,
	// use a standard HBAppearanceSettings with the defaults
	HBAppearanceSettings *appearanceSettings = ((UINavigationItem *)self.navigationItems.lastObject).hb_appearanceSettings ?: [[HBAppearanceSettings alloc] init];

	// set it on ourselves in case other things need it
	self.hb_appearanceSettings = appearanceSettings;

	UIColor *backgroundColor = nil;

	// if the navigation bar is inverted
	if (appearanceSettings.invertedNavigationBar) {
		// use a shade of grey for tint color
		self.tintColor = [UIColor colorWithWhite:247.f / 255.f alpha:1];

		// we also want the background color to be the navigation bar tint color or
		// standard tint color if that’s nil
		backgroundColor = appearanceSettings.navigationBarTintColor ?: appearanceSettings.tintColor;
	} else {
		// try the navigation bar tint color. if nil, use the standard tint color
		// (which could also be nil)
		self.tintColor = appearanceSettings.navigationBarTintColor ?: appearanceSettings.tintColor;
	}

	// if we have a custom tint color, or we no longer have a custom tint color,
	// but one is currently set, and it should be animated, ask for it to be
	if ((backgroundColor || self.barTintColor) && animated) {
		animateBarTintColor = YES;
	}

	// set the bar tint color
	self.barTintColor = backgroundColor;
}

%end

#pragma mark - Animation hack

%hook _UIBackdropView

- (void)applySettings:(id)settings {
	if (animateBarTintColor) {
		animateBarTintColor = NO;

		[UIView animateWithDuration:0.2 animations:^{
			%orig;
		}];
	} else {
		%orig;
	}
}

%end

#pragma mark - Constructor

%ctor {
	// this entire thing isn't particularly useful if the OS doesn’t support it
	if (!IS_IOS_OR_NEWER(iOS_7_0)) {
		return;
	}
	
	%init;

	if (IS_IOS_OR_NEWER(iOS_9_0)) {
		%init(EddyCue);
	} else if (IS_IOS_OR_NEWER(iOS_8_0)) {
		%init(CraigFederighi);
	} else {
		%init(JonyIve);
	}
}
