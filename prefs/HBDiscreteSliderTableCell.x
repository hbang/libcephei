#import "HBDiscreteSliderTableCell.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIColor+Private.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>

@implementation HBDiscreteSliderTableCell

@dynamic control;

#pragma mark - PSControlTableCell

- (PSDiscreteSlider *)newControl {
	PSDiscreteSlider *slider = [[%c(PSDiscreteSlider) ?: UISlider.class alloc] initWithFrame:CGRectZero];

	if ([slider respondsToSelector:@selector(setTrackMarkersColor:)]) {
		slider.trackMarkersColor = [UIColor colorWithWhite:0.596078f alpha:1];
	}

	return slider;
}

@end
