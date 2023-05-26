#import <Preferences/PSListController.h>
#import <UIKit/UIImage+Private.h>
#import "../main/HBRespringController.h"
#import "../main/HBOutputForShellCommand.h"
#import <CepheiUI/CepheiUI.h>

NS_ASSUME_NONNULL_BEGIN

@class HBAppearanceSettings;

static NSString *const cepheiVersion = @CEPHEI_VERSION;
static NSString *const installPrefix = @INSTALL_PREFIX;

@interface HBRespringController (Private)
+ (NSURL *)_preferencesReturnURL;
@end

NS_ASSUME_NONNULL_END
