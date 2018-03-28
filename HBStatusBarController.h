#import <Foundation/Foundation.h>
#import "HBStatusBarItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBStatusBarController : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) NSSet <HBStatusBarItem *> *customStatusBarItems;

- (void)addItem:(HBStatusBarItem *)item;
- (void)removeItem:(HBStatusBarItem *)item;

@end

NS_ASSUME_NONNULL_END
