#import "UINavigationItem+HBTintAdditions.h"

%hook UINavigationItem

%property (nonatomic, retain) HBAppearanceSettings *hb_appearanceSettings;

- (void)dealloc {
	[self.hb_appearanceSettings release];

	%orig;
}

%end
