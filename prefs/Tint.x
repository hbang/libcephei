#import "UINavigationItem+HBTintAdditions.h"
#import <UIKit/UINavigationBar+Private.h>
#import <version.h>

@interface UINavigationBar (HBTintAdditions)

@property (nonatomic, copy) UIColor *hb_tintColor;
@property (nonatomic, copy) UIColor *hb_navigationBarTintColor;
@property (nonatomic, copy) UIColor *hb_navigationBarTextColor;
@property (nonatomic, copy) UIColor *hb_navigationBarBackgroundColor;

- (void)_hb_updateTintColorsAnimated:(BOOL)animated;

@end

BOOL animateBarTintColor = NO;

%hook UINavigationBar

%property (nonatomic, copy) UIColor *hb_tintColor;
%property (nonatomic, copy) UIColor *hb_navigationBarTintColor;
%property (nonatomic, copy) UIColor *hb_navigationBarTextColor;
%property (nonatomic, copy) UIColor *hb_navigationBarBackgroundColor;

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
	return self.hb_navigationBarTextColor ?: %orig;
}

/*
 If needed, and possible, runs through every navigation item on the current
 navigation stack, pulling the libcephei tintColor from the previous
 HBListController.
*/
%new - (void)_hb_updateTintColorsAnimated:(BOOL)animated {
	[self.hb_tintColor release];
	self.hb_tintColor = nil;
	[self.hb_navigationBarTintColor release];
	self.hb_navigationBarTintColor = nil;
	[self.hb_navigationBarTextColor release];
	self.hb_navigationBarTextColor = nil;
	[self.hb_navigationBarBackgroundColor release];
	self.hb_navigationBarBackgroundColor = nil;

	NSArray *items = self.navigationItems;

	if (items.count == 0) {
		return;
	}

	for (UINavigationItem *item in items.reverseObjectEnumerator) {
		if (item.hb_tintColor) {
			self.hb_tintColor = [item.hb_tintColor copy];
			self.hb_navigationBarTintColor = [item.hb_navigationBarTintColor copy];
			self.hb_navigationBarTextColor = [item.hb_navigationBarTextColor copy];
			self.hb_navigationBarBackgroundColor = [item.hb_navigationBarBackgroundColor copy];

			break;
		}
	}

	self.tintColor = self.hb_navigationBarTintColor;

	// if we have a custom tint color, or we no longer have a custom tint color,
	// but one is currently set, and it should be animated, ask for it to be
	if ((self.hb_navigationBarBackgroundColor || self.barTintColor) && animated) {
		animateBarTintColor = YES;
	}

	self.barTintColor = self.hb_navigationBarBackgroundColor;
}

#pragma mark - Memory management

- (void)dealloc {
	[self.hb_tintColor release];
	[self.hb_navigationBarTintColor release];
	[self.hb_navigationBarTextColor release];
	[self.hb_navigationBarBackgroundColor release];

	%orig;
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
	// this entire thing isn't particularly useful if the OS doesn't support it
	if (IS_MODERN) {
		%init;
	}

	if (IS_IOS_OR_NEWER(iOS_9_0)) {
		%init(EddyCue);
	} else if (IS_IOS_OR_NEWER(iOS_8_0)) {
		%init(CraigFederighi);
	} else {
		%init(JonyIve);
	}
}
