#import "UINavigationItem+HBTintAdditions.h"

%hook UINavigationItem

%property (nonatomic, copy) UIColor *hb_tintColor;
%property (nonatomic, copy) UIColor *hb_navigationBarTintColor;
%property (nonatomic, copy) UIColor *hb_navigationBarTextColor;
%property (nonatomic, copy) UIColor *hb_navigationBarBackgroundColor;

- (void)dealloc {
	[self.hb_tintColor release];
	[self.hb_navigationBarTintColor release];
	[self.hb_navigationBarTextColor release];
	[self.hb_navigationBarBackgroundColor release];

	%orig;
}

%end
