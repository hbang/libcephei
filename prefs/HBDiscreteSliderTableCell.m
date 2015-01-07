#import "HBDiscreteSliderTableCell.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIColor+Private.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>

@implementation HBDiscreteSliderTableCell

#pragma mark - PSControlTableCell

- (PSDiscreteSlider *)newControl {
	PSDiscreteSlider *slider = [[PSDiscreteSlider alloc] initWithFrame:CGRectZero];
	slider.trackMarkersColor = [UIColor colorWithWhite:0.596078f alpha:1];
	return slider;
}

@end
