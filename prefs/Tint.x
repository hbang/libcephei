#import "HBAppearanceSettings.h"
#import "UINavigationItem+HBTintAdditions.h"
#import "../ui/UIColor+HBAdditions.h"
#import <UIKit/UINavigationBar+Private.h>
#import <version.h>

#if !ROOTLESS
@interface UINavigationBar (HBTintAdditions)

@property (nonatomic, copy) HBAppearanceSettings *hb_appearanceSettings;

- (void)_hb_updateTintColorsAnimated:(BOOL)animated;

@end

static BOOL animateBarTintColor = NO;

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
	// If the navigation bar is inverted then we use white, otherwise we use the provided title color,
	// and if that is nil then fall back to orig.
	// shush clang i know the thing i deprecated is deprecated
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	if (self.hb_appearanceSettings.invertedNavigationBar) {
#pragma clang diagnostic pop
		return [UIColor whiteColor];
	}

	return self.hb_appearanceSettings.navigationBarTitleColor ?: %orig;
}

%new - (void)_hb_updateTintColorsAnimated:(BOOL)animated {
	// Get the appearance settings from the top item on the stack. If it’s nil, use a standard
	// HBAppearanceSettings with the defaults.
	HBAppearanceSettings *appearanceSettings = ((UINavigationItem *)self.navigationItems.lastObject).hb_appearanceSettings ?: [[HBAppearanceSettings alloc] init];

	// Set it on ourselves in case other things need it
	self.hb_appearanceSettings = appearanceSettings;

	UIColor *backgroundColor = nil;

	// If the navigation bar is inverted (deprecated)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	if (self.hb_appearanceSettings.invertedNavigationBar) {
#pragma clang diagnostic pop
		// Use a hardcoded grey value for tint color
		self.tintColor = [UIColor colorWithWhite:247.f / 255.f alpha:1];

		// We want the background color to be the navigation bar tint color, or standard tint color if
		// that’s nil
		backgroundColor = [appearanceSettings.navigationBarTintColor ?: appearanceSettings.tintColor hb_colorWithDarkInterfaceVariant];
	} else {
		// Try the navigation bar tint color. If nil, use the standard tint color (which could also
		// be nil).
		self.tintColor = [appearanceSettings.navigationBarTintColor ?: appearanceSettings.tintColor hb_colorWithDarkInterfaceVariant];

		// Use the specified background color if one has been set, otherwise leave it unchanged (nil).
		backgroundColor = appearanceSettings.navigationBarBackgroundColor;
	}

	// If we have a custom tint color, or we no longer have a custom tint color, but one is currently
	// set, and it should be animated, ask for it to be. Not needed on iOS 13.0+ thanks to the
	// UINavigationBarAppearance API.
	if (IS_IOS_OR_NEWER(iOS_7_0) && !IS_IOS_OR_NEWER(iOS_13_0)) {
		if ((backgroundColor || self.barTintColor) && animated) {
			animateBarTintColor = YES;
		}
		self.barTintColor = backgroundColor;
	}
}

%end

%group JonyIve
%hook UINavigationBar
- (void)_setItems:(NSArray *)items transition:(NSInteger)transition {
	%orig;
	[self _hb_updateTintColorsAnimated:transition != 0];
}
%end
%end

%group CraigFederighi
%hook UINavigationBar
- (void)_setItems:(NSArray *)items transition:(NSInteger)transition reset:(BOOL)reset {
	%orig;
	[self _hb_updateTintColorsAnimated:transition != 0];
}
%end
%end

%group EddyCue
%hook UINavigationBar
- (void)_setItems:(NSArray *)items transition:(NSInteger)transition reset:(BOOL)reset resetOwningRelationship:(BOOL)resetOwningRelationship {
	%orig;
	[self _hb_updateTintColorsAnimated:transition != 0];
}
%end
%end

#pragma mark - Animation hack

%group BackdropHax
%hook _UIBackdropView

- (void)applySettings:(id)settings {
	// Hackishly make the backdrop change be animated by wrapping it in a UIView animation block.
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
%end

#pragma mark - Constructor

%ctor {
	// This entire thing isn’t particularly useful if the OS doesn’t support it
	if (!IS_IOS_OR_NEWER(iOS_6_0)) {
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

	if (IS_IOS_OR_NEWER(iOS_7_0) && !IS_IOS_OR_NEWER(iOS_13_0)) {
		%init(BackdropHax);
	}
}
#endif
