#import "UIStatusBarCustomItem.h"
#import "HBStatusBarItem.h"

NS_ASSUME_NONNULL_BEGIN

/// `UIStatusBarCustomItem` from Cephei Status Bar is provided as a compatibility layer for
/// libstatusbar. Items displayed using this API **will not** display on iPhone X.
@interface LSStatusBarItem : HBStatusBarItem

- (instancetype)initWithIdentifier:(NSString *)identifier alignment:(UIStatusBarCustomItemAlignment)alignment;

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, readonly) UIStatusBarCustomItemAlignment alignment;

@property (nonatomic, getter=isVisible) BOOL visible;
@property (nonatomic, strong) NSString *imageName;

/// Whether the item can only be refreshed by calling the update method.
///
/// This disables automatic updating of the item after the value of alignment, isVisible, or
/// iconName changes. Call update to manually invoke an update.
@property (nonatomic, readonly, getter=isManualUpdate) BOOL manualUpdate;

/// Marks the item as needing to be redrawn.
///
/// You must call this to ensure your item is updated when isManualUpdate is set to YES.
- (void)update;

@end

NS_ASSUME_NONNULL_END
