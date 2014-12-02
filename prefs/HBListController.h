#import <Preferences/PSListController.h>

#define IS_MODERN IS_IOS_OR_NEWER(iOS_7_0)
#define IS_MOST_MODERN IS_IOS_OR_NEWER(iOS_8_0)

@interface HBListController : PSListController

+ (UIColor *)hb_tintColor;

@end
