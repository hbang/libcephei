#import "UIColor+HBAdditions.h"
#import <_Prefix/IOSWebKitCompatHacks.h>
#import <WebKit/WebView.h>
#import <WebKit/WebFrame.h>
#import <WebKit/DOMDocument.h>
#import <WebKit/DOMHTMLDivElement.h>
#import <WebKit/DOMCSSStyleDeclaration.h>
#import <WebKit/DOMCSSPrimitiveValue.h>
#import <WebKit/DOMRGBColor.h>

@interface DOMCSSStyleDeclaration ()
@property (nonatomic, strong) UIColor *color;
@end

@implementation UIColor (HBAdditions)

+ (instancetype)hb_colorWithPropertyListValue:(id)value {
	return [[self alloc] hb_initWithPropertyListValue:value];
}

- (instancetype)hb_initWithPropertyListValue:(id)value {
	if (!value) {
		return nil;
	} else if ([value isKindOfClass:NSArray.class] && ((NSArray *)value).count == 3) {
		NSArray *array = value;
		return [self initWithRed:((NSNumber *)array[0]).integerValue / 255.f
		                   green:((NSNumber *)array[1]).integerValue / 255.f
		                    blue:((NSNumber *)array[2]).integerValue / 255.f
		                   alpha:1];
	} else if ([value isKindOfClass:NSString.class]) {
		NSString *string = value;
		if ([string hasPrefix:@"#"] && (string.length == 7 || string.length == 8 || string.length == 4 || string.length == 5)) {
			if (string.length == 4 || string.length == 5) {
				NSString *r = [string substringWithRange:NSMakeRange(1, 1)];
				NSString *g = [string substringWithRange:NSMakeRange(2, 1)];
				NSString *b = [string substringWithRange:NSMakeRange(3, 1)];
				NSString *a = string.length == 5 ? [string substringWithRange:NSMakeRange(4, 1)] : @"FF";
				string = [NSString stringWithFormat:@"#%1$@%1$@%2$@%2$@%3$@%3$@%4$@%4$@", r, g, b, a];
			}

			unsigned int hex = 0;
			NSScanner *scanner = [NSScanner scannerWithString:string];
			scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"#"];
			[scanner scanHexInt:&hex];

			if (string.length == 8) {
				return [self initWithRed:((hex & 0xFF000000) >> 24) / 255.f
				                   green:((hex & 0x00FF0000) >> 16) / 255.f
				                    blue:((hex & 0x0000FF00) >> 8)  / 255.f
				                   alpha:((hex & 0x000000FF) >> 1)  / 255.f];
			} else {
				return [self initWithRed:((hex & 0xFF0000) >> 16) / 255.f
				                   green:((hex & 0x00FF00) >> 8)  / 255.f
				                    blue:((hex & 0x0000FF) >> 1)  / 255.f
				                   alpha:1];
			}
		} else if ([string rangeOfString:@"("].location != NSNotFound) {
			return [self _hb_initWithCSSValue:value];
		}
	}

	return nil;
}

- (instancetype)_hb_initWithCSSValue:(id)value {
	static dispatch_once_t onceToken;
	static WebView *webView;
	static DOMHTMLDivElement *div;
	dispatch_once(&onceToken, ^{
		webView = [[WebView alloc] init];
		DOMDocument *document = webView.mainFrame.DOMDocument;
		div = (DOMHTMLDivElement *)[document createElement:@"div"];
		[document.body appendChild:div];
	});

	div.style.color = value;

	DOMDocument *document = webView.mainFrame.DOMDocument;
	DOMCSSStyleDeclaration *computedStyle = [document getComputedStyle:div pseudoElement:nil];
	DOMCSSPrimitiveValue *cssValue = (DOMCSSPrimitiveValue *)[computedStyle getPropertyCSSValue:@"color"];

	if (cssValue) {
		DOMRGBColor *color = cssValue.getRGBColorValue;
		CGFloat components[4] = {
			[color.red getFloatValue:DOM_CSS_PRIMITIVE_VALUE] / 255.f,
			[color.green getFloatValue:DOM_CSS_PRIMITIVE_VALUE] / 255.f,
			[color.blue getFloatValue:DOM_CSS_PRIMITIVE_VALUE] / 255.f,
			[color.alpha getFloatValue:DOM_CSS_PRIMITIVE_VALUE]
		};

		return [self initWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
	}

	return nil;
}

@end
