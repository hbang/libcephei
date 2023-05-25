#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <MobileCoreServices/LSApplicationProxy.h>
#import <MobileCoreServices/LSApplicationWorkspace.h>
#import <UIKit/UIImage+Private.h>
#import "../HBOutputForShellCommand.h"
#import "../HBRespringController.h"
#import "HBLinkTableCell.h"
#import "HBMastodonTableCell.h"
#import "HBPackageTableCell.h"
#import "HBSupportController.h"
#import "PSListController+HBTintAdditions.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const cepheiVersion = @CEPHEI_VERSION;
static NSString *const installPrefix = @INSTALL_PREFIX;

@interface HBRespringController (Private)
+ (NSURL *)_preferencesReturnURL;
@end

NS_ASSUME_NONNULL_END
