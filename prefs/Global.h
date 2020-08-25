@class NSBundle;

#pragma mark - Macros

#define LOCALIZE(key, table, comment) NSLocalizedStringFromTableInBundle(key, table ?: @"Localizable", cepheiGlobalBundle, comment)

#pragma mark - Variables

extern NSBundle *cepheiGlobalBundle;
