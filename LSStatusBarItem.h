#import "UIStatusBarCustomItem.h"

@interface LSStatusBarItem : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier alignment:(UIStatusBarCustomItemAlignment)alignment;

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, readonly) UIStatusBarCustomItemAlignment alignment;

@property (nonatomic, getter=isVisible) BOOL visible;
@property (nonatomic, strong) NSString *imageName;

@property (nonatomic, readonly, getter=isManualUpdate) BOOL manualUpdate;

- (void)update;

@end
