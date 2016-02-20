#import "PSListController+HBTintAdditions.h"
#import "UINavigationItem+HBTintAdditions.h"

@interface PSListController ()

@property (nonatomic, retain) HBAppearanceSettings *_hb_internalAppearanceSettings;

@end

@implementation PSListController (HBTintAdditions)

@dynamic hb_appearanceSettings;

@end

%hook PSListController

%property (nonatomic, retain) HBAppearanceSettings *_hb_internalAppearanceSettings;

#pragma mark - NSObject

- (id)init {
	self = %orig;

	if (self) {
		self.hb_appearanceSettings = [[HBAppearanceSettings alloc] init];
	}

	return self;
}

#pragma mark - Getter/setter

%new - (HBAppearanceSettings *)hb_appearanceSettings {
	return self._hb_internalAppearanceSettings;
}

%new - (void)hb_setAppearanceSettings:(HBAppearanceSettings *)appearanceSettings {
	%log;

	// if appearanceSettings is nil, instantiate a generic appearance object
	if (!appearanceSettings) {
		appearanceSettings = [[HBAppearanceSettings alloc] init];
	}

	// set the internal property
	[self._hb_internalAppearanceSettings release];
	self._hb_internalAppearanceSettings = [appearanceSettings copy];

	// the navigation item also needs access to the appearance settings
	[self.navigationItem.hb_appearanceSettings release];
	self.navigationItem.hb_appearanceSettings = self._hb_internalAppearanceSettings;
}

#pragma mark - Memory management

- (void)dealloc {
	[self.hb_appearanceSettings release];
	%orig;
}

%end
