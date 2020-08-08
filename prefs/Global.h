@class NSBundle;

#pragma mark - Macros

#define LOCALIZE(key, table, comment) NSLocalizedStringFromTableInBundle(key, table ?: @"Localizable", globalBundle, comment)

#pragma mark - Variables

static NSBundle *globalBundle;
