NSBundle *globalBundle;

#define L18N(key) [globalBundle localizedStringForKey:key value:key table:@"libhbangprefs"]
#define URL_ENCODE(string) [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8) autorelease]

#define IS_MODERN IS_IOS_OR_NEWER(iOS_7_0)
#define IS_MOST_MODERN IS_IOS_OR_NEWER(iOS_8_0)
