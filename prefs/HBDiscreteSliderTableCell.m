#import "HBDiscreteSliderTableCell.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIColor+Private.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>
#include <objc/runtime.h>

Class $PSSliderTableCell, $PSDiscreteSlider, $PSSegmentableSlider;

@implementation HBDiscreteSliderTableCell

@dynamic control;

+ (void)initialize {
	[super initialize];
	
	$PSSliderTableCell = objc_getClass("PSSliderTableCell");
	$PSDiscreteSlider = objc_getClass("PSDiscreteSlider");
	$PSSegmentableSlider = objc_getClass("PSSegmentableSlider");

	if ($PSSliderTableCell) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
		class_setSuperclass(self, $PSSliderTableCell);
#pragma clang diagnostic pop
	}
}

#pragma mark - PSTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	// for iOS 8.2+, use built in isSegmented style
	specifier.properties[@"isSegmented"] = @YES;
	return [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
}

#pragma mark - PSControlTableCell

- (PSDiscreteSlider *)newControl {
	Class sliderClass = UISlider.class;

	if ($PSDiscreteSlider) {
		sliderClass = $PSDiscreteSlider;
	} else if ($PSSegmentableSlider) {
		sliderClass = $PSSegmentableSlider;
	}

	PSDiscreteSlider *slider = [[sliderClass alloc] initWithFrame:CGRectZero];

	if ([slider respondsToSelector:@selector(setTrackMarkersColor:)]) {
		slider.trackMarkersColor = [UIColor colorWithWhite:0.596078f alpha:1];
	}

	return slider;
}

@end
