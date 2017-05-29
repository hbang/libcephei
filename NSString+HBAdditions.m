#import "NSString+HBAdditions.h"

@implementation NSString (HBAdditions)

- (NSString *)hb_stringByEncodingQueryPercentEscapes {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?&=;+!@#$()',*"), kCFStringEncodingUTF8));
}

- (NSString *)hb_stringByDecodingQueryPercentEscapes {
	NSString *newString = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
	return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)newString, CFSTR("")));
}

- (NSDictionary *)hb_queryStringComponents {
	if (self.length < 3 || [self rangeOfString:@"="].location == NSNotFound) {
		return @{};
	}

	NSArray <NSString *> *items = [self componentsSeparatedByString:@"&"];
	NSMutableDictionary <NSString *, NSString *> *newItems = [NSMutableDictionary dictionary];

	for (NSString *item in items) {
		NSRange equalsRange = [item rangeOfString:@"="];
		NSString *key, *value;

		if (equalsRange.location == NSNotFound) {
			key = item.hb_stringByDecodingQueryPercentEscapes;
			value = @"";
		} else {
			key = [item substringWithRange:NSMakeRange(0, equalsRange.location)].hb_stringByDecodingQueryPercentEscapes;
			value = [item substringWithRange:NSMakeRange(equalsRange.location + 1, item.length - equalsRange.location - 1)].hb_stringByDecodingQueryPercentEscapes;
		}

		newItems[key] = value;
	}

	return newItems;
}

@end
