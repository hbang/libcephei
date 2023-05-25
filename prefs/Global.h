#import "../Global.h"

NS_ASSUME_NONNULL_BEGIN

@class NSBundle;

#pragma mark - Macros

#define LOCALIZE(key, table, comment) NSLocalizedStringFromTableInBundle(key, table ?: @"Localizable", cepheiGlobalBundle, comment)
#define kHBCepheiUserAgent [NSString stringWithFormat:@"Cephei/%s iOS/%@ (+https://hbang.github.io/libcephei/)", CEPHEI_VERSION, [UIDevice currentDevice].systemVersion]

#pragma mark - Variables

extern NSBundle *cepheiGlobalBundle;

NS_ASSUME_NONNULL_END
