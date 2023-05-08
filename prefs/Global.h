#import "../Global.h"

NS_ASSUME_NONNULL_BEGIN

@class NSBundle;

#pragma mark - Macros

#define LOCALIZE(key, table, comment) NSLocalizedStringFromTableInBundle(key, table ?: @"Localizable", cepheiGlobalBundle, comment)
#define kHBCepheiUserAgent [NSString stringWithFormat:@"Cephei/%s iOS/%@ (+https://hbang.github.io/libcephei/)", CEPHEI_VERSION, [UIDevice currentDevice].systemVersion]

#pragma mark - Variables

extern NSBundle *cepheiGlobalBundle;

#pragma mark - Hack

@interface UIColor ()

+ (nullable instancetype)hb_colorWithPropertyListValue:(id)value NS_SWIFT_UNAVAILABLE("");
- (nullable instancetype)initWithPropertyListValue:(id)value NS_SWIFT_NAME(init(propertyListValue:));
- (UIColor *)hb_colorWithDarkInterfaceVariant NS_SWIFT_NAME(withDarkInterfaceVariant());

@end

NS_ASSUME_NONNULL_END
