#pragma mark - Macros

#define LOCALIZE(key, table, comment) NSLocalizedStringFromTableInBundle(key, table ?: @"Localizable", globalBundle, comment)

// percent encoding macro. iOS 9 of course made this more interesting, finally
// adding an actual api for this, but we support way older than that here…
#define URL_ENCODE(string) ([NSString instancesRespondToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)] \
	? [(string) stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] \
	: (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8)))

#pragma mark - Variables

extern NSBundle *globalBundle;
