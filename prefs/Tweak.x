#import <UIKit/UIKit.h>

static NSInteger const kUISliderLabelTag = 1986096245;

%hook UISlider

- (void)_layoutSubviewsForBoundsChange:(BOOL)something {
	%orig;

	UILabel *label = (UILabel *)[self viewWithTag:kUISliderLabelTag];
	label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

%end
