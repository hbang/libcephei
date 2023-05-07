@import UIKit;
@import ObjectiveC;
#import "../ui/UIColor+HBAdditions.h"
#import <MobileIcons/MobileIcons.h>
#import <UIKit/UIImage+Private.h>
#import <HBLog.h>

static inline UIImage *iconFromColorAndGlyph(UIColor *color, BOOL isBig, UIImage *glyph) {
	CGFloat iconSize = isBig ? 40.f : 29.f;
	CGRect iconRect = CGRectMake(0, 0, iconSize, iconSize);
	UIGraphicsBeginImageContextWithOptions(iconRect.size, NO, [UIScreen mainScreen].scale);
	[color setFill];
	UIRectFill(iconRect);

	if (glyph != nil) {
		// Scale to fit 80% of the icon size
		CGFloat glyphBaseSize = ceilf(iconSize * 0.8f);
		CGSize glyphSize = CGSizeMake(glyphBaseSize, glyphBaseSize);
		if (glyph.size.width > glyph.size.height) {
			glyphSize.height /= glyph.size.width / glyph.size.height;
		} else if (glyph.size.height > glyph.size.width) {
			glyphSize.width /= glyph.size.height / glyph.size.width;
		}
		CGRect glyphRect = CGRectInset(iconRect, (iconSize - glyphSize.width) / 2, (iconSize - glyphSize.height) / 2);
		[glyph drawInRect:glyphRect];
	}

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return [image _applicationIconImageForFormat:isBig ? MIIconVariantSpotlight : MIIconVariantSmall precomposed:YES scale:[UIScreen mainScreen].scale];
}

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

	UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:pointSize weight:weight scale:scale];
	UIImage *symbolImage = [UIImage systemImageNamed:name withConfiguration:configuration];

	// Background color
	if (params[@"backgroundColor"] != nil) {
		UIColor *backgroundColor = [UIColor hb_colorWithPropertyListValue:params[@"backgroundColor"]];
		if (backgroundColor != nil) {
			symbolImage = [symbolImage imageWithTintColor:tintColor ?: [UIColor whiteColor] renderingMode:renderingMode];
			return iconFromColorAndGlyph(backgroundColor, NO, symbolImage);
		}
	}
	return [symbolImage imageWithTintColor:tintColor renderingMode:renderingMode];
}
