@import UIKit;
@import ObjectiveC;
#import "../ui/UIColor+HBAdditions.h"

static Class $UIImageSymbolConfiguration;

static inline UIImageSymbolWeight systemSymbolWeightFromValue(id value) NS_AVAILABLE_IOS(13_0) {
	if ([value isKindOfClass:NSNumber.class]) {
		return ((NSNumber *)value).integerValue;
	}

	static NSDictionary <NSString *, NSNumber *> *values;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		values = @{
			@"UIImageSymbolWeightUltraLight": @(UIImageSymbolWeightUltraLight),
			@"UIImageSymbolWeightThin":       @(UIImageSymbolWeightThin),
			@"UIImageSymbolWeightLight":      @(UIImageSymbolWeightLight),
			@"UIImageSymbolWeightRegular":    @(UIImageSymbolWeightRegular),
			@"UIImageSymbolWeightMedium":     @(UIImageSymbolWeightMedium),
			@"UIImageSymbolWeightSemibold":   @(UIImageSymbolWeightSemibold),
			@"UIImageSymbolWeightBold":       @(UIImageSymbolWeightBold),
			@"UIImageSymbolWeightHeavy":      @(UIImageSymbolWeightHeavy),
			@"UIImageSymbolWeightBlack":      @(UIImageSymbolWeightBlack),
			@"ultraLight": @(UIImageSymbolWeightUltraLight),
			@"thin":       @(UIImageSymbolWeightThin),
			@"light":      @(UIImageSymbolWeightLight),
			@"regular":    @(UIImageSymbolWeightRegular),
			@"medium":     @(UIImageSymbolWeightMedium),
			@"semibold":   @(UIImageSymbolWeightSemibold),
			@"bold":       @(UIImageSymbolWeightBold),
			@"heavy":      @(UIImageSymbolWeightHeavy),
			@"black":      @(UIImageSymbolWeightBlack)
		};
	});
	return values[value] ? values[value].integerValue : UIImageSymbolWeightRegular;
}

static inline UIImageSymbolScale systemSymbolScaleFromValue(id value) NS_AVAILABLE_IOS(13_0) {
	if ([value isKindOfClass:NSNumber.class]) {
		return ((NSNumber *)value).integerValue;
	}

	static NSDictionary <NSString *, NSNumber *> *values;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		values = @{
			@"UIImageSymbolScaleSmall":  @(UIImageSymbolScaleSmall),
			@"UIImageSymbolScaleMedium": @(UIImageSymbolScaleMedium),
			@"UIImageSymbolScaleLarge":  @(UIImageSymbolScaleLarge),
			@"small":  @(UIImageSymbolScaleSmall),
			@"medium": @(UIImageSymbolScaleMedium),
			@"large":  @(UIImageSymbolScaleLarge)
		};
	});
	return values[value] ? values[value].integerValue : UIImageSymbolScaleMedium;
}

static inline UIImage *systemSymbolImageForDictionary(NSDictionary <NSString *, id> *params) NS_AVAILABLE_IOS(13_0) {
	NSString *name = params[@"name"];
	CGFloat pointSize = ((NSNumber *)params[@"pointSize"]).doubleValue ?: 20.0;
	UIImageSymbolWeight weight = systemSymbolWeightFromValue(params[@"weight"]);
	UIImageSymbolScale scale = systemSymbolScaleFromValue(params[@"scale"]);

	// Tint color: If we have one, use original mode, otherwise inherit tint color via template mode.
	UIColor *tintColor = [UIColor hb_colorWithPropertyListValue:params[@"tintColor"]];
	UIImageRenderingMode renderingMode = tintColor ? UIImageRenderingModeAlwaysOriginal : UIImageRenderingModeAlwaysTemplate;

	if ($UIImageSymbolConfiguration == nil) {
		$UIImageSymbolConfiguration = objc_getClass("UIImageSymbolConfiguration");
	}
	UIImageSymbolConfiguration *configuration = [$UIImageSymbolConfiguration configurationWithPointSize:pointSize weight:weight scale:scale];
	return [[UIImage systemImageNamed:name withConfiguration:configuration] imageWithTintColor:tintColor renderingMode:renderingMode];
}
