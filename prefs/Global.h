@class NSBundle;

#pragma mark - Macros

#define LOCALIZE(key, table, comment) NSLocalizedStringFromTableInBundle(key, table ?: @"Localizable", cepheiGlobalBundle, comment)
#define kHBCepheiUserAgent [NSString stringWithFormat:@"Cephei/%s iOS/%@", CEPHEI_VERSION, [UIDevice currentDevice].systemVersion]

#pragma mark - Variables

extern NSBundle *cepheiGlobalBundle;
