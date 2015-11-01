extern NSBundle *globalBundle;

#define LOCALIZE(key, table, comment) NSLocalizedStringFromTableInBundle(key, table ?: @"Localizable", globalBundle, comment)

#define URL_ENCODE(string) [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8) autorelease]

#define IS_MODERN IS_IOS_OR_NEWER(iOS_7_0)
#define IS_MOST_MODERN IS_IOS_OR_NEWER(iOS_8_0)
