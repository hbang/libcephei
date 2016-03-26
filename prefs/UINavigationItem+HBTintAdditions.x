#import "UINavigationItem+HBTintAdditions.h"

%hook UINavigationItem

%property (nonatomic, retain) HBAppearanceSettings *hb_appearanceSettings;

%end
