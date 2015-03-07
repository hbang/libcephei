#import "HBDiscreteSliderTableCell.h"
#import <version.h>

#pragma mark - iOS < 7 UISlider label fix

static NSInteger const kUISliderLabelTag = 1986096245;

%hook UISlider

- (void)_layoutSubviewsForBoundsChange:(BOOL)something {
	%orig;

	UILabel *label = (UILabel *)[self viewWithTag:kUISliderLabelTag];
	label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

%end

#pragma mark - Version-specific runtime changes

%ctor {
	if (IS_IOS_OR_NEWER(iOS_7_0)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
		class_setSuperclass(HBDiscreteSliderTableCell.class, %c(PSSliderTableCell));
#pragma clang diagnostic pop
	}
}
