#import "UIColor+HBAdditions.h"

@implementation UIColor (HBAdditions)

+ (instancetype)hb_colorWithPropertyListValue:(id)value {
	return [[self alloc] hb_initWithPropertyListValue:value];
}

- (instancetype)hb_initWithPropertyListValue:(id)value {
	if (!value) {
		return nil;
	} else if ([value isKindOfClass:NSArray.class] && ((NSArray *)value).count == 3) {
		NSArray *array = value;
		return [UIColor colorWithRed:((NSNumber *)array[0]).integerValue / 255.f green:((NSNumber *)array[1]).integerValue / 255.f blue:((NSNumber *)array[2]).integerValue / 255.f alpha:1];
	} else if ([value isKindOfClass:NSString.class] && [((NSString *)value) hasPrefix:@"#"] && ((NSString *)value).length == 7) {
		unsigned int hexInteger = 0;
		NSScanner *scanner = [NSScanner scannerWithString:value];
		scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"#"];
		[scanner scanHexInt:&hexInteger];

		return [UIColor colorWithRed:((hexInteger & 0xFF0000) >> 16) / 255.f green:((hexInteger & 0xFF00) >> 8) / 255.f blue:(hexInteger & 0xFF) / 255.f alpha:1];
	} else {
		return nil;
	}
}

@end
