#import "NSDictionary+HBAdditions.h"
#import "NSString+HBAdditions.h"

@implementation NSDictionary (HBAdditions)

- (NSString *)hb_queryString {
	// NSURLComponents will do this in a more "right" way, but NSURLQueryItem was only introduced in
	// iOS 8. if we're on an older iOS version, fall back to manually constructing the query string
	if (%c(NSURLQueryItem)) {
		NSURLComponents *components = [[%c(NSURLComponents) alloc] init];
		NSMutableArray <NSURLQueryItem *> *queryItems = [NSMutableArray array];

		for (NSString *key in self.allKeys) {
			[queryItems addObject:[%c(NSURLQueryItem) queryItemWithName:key value:self[key]]];
		}

		components.queryItems = queryItems;
		return components.URL.query ?: @"";
	} else {
		NSMutableArray <NSString *> *queryItems = [NSMutableArray array];

		for (NSString *key in self.allKeys) {
			BOOL hasValue = ![self[key] isKindOfClass:NSNull.class];

			[queryItems addObject:[NSString stringWithFormat:@"%@%@%@",
				key.hb_stringByEncodingQueryPercentEscapes,
				hasValue ? @"=" : @"",
				hasValue ? ((NSObject *)self[key]).description.hb_stringByEncodingQueryPercentEscapes : @""]];
		}

		return [queryItems componentsJoinedByString:@"&"];
	}
}

@end
