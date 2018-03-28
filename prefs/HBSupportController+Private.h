#import "HBSupportController.h"

@class TSPackage;

@interface HBSupportController (Private)

+ (nullable TSPackage *)_packageForIdentifier:(nullable NSString *)identifier orFile:(nullable NSString *)file;

@end
