#pragma mark - ARC macros

#if __has_feature(objc_arc)
	#define RETAIN(thing) thing
	#define AUTORELEASE(thing) thing
#else
	#define RETAIN(thing) [thing retain]
	#define AUTORELEASE(thing) [thing autorelease]
#endif

#pragma mark - Other macros

#define LOCALIZE(key, table, comment) NSLocalizedStringFromTableInBundle(key, table ?: @"Localizable", globalBundle, comment)
#define URL_ENCODE(string) (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8)

#define IS_MODERN IS_IOS_OR_NEWER(iOS_7_0)
#define IS_MOST_MODERN IS_IOS_OR_NEWER(iOS_8_0)

#pragma mark - Variables

extern NSBundle *globalBundle;

