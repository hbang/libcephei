#import <TechSupport/TSContactViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBSupportController : NSObject

+ (TSPackage *)packageForIdentifier:(nullable NSString *)identifier orFile:(nullable NSString *)file;

+ (TSContactViewController *)supportViewControllerForBundle:(nullable NSBundle *)bundle preferencesIdentifier:(nullable NSString *)preferencesIdentifier supportInstructions:(NSArray *)supportInstructions;

@end

NS_ASSUME_NONNULL_END
