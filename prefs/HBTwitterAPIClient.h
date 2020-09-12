@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class HBTwitterAPIClient;

@protocol HBTwitterAPIClientDelegate <NSObject>

- (void)twitterAPIClientDidLoadUsername:(NSString *)username profileImage:(UIImage *)profileImage;

@end

@interface HBTwitterAPIClient : NSObject

+ (instancetype)sharedInstance;

- (void)queueLookupsForUsernames:(NSArray <NSString *> *)usernames userIDs:(NSArray <NSString *> *)userIDs;

- (void)addDelegate:(id <HBTwitterAPIClientDelegate>)delegate forUsername:(nullable NSString *)username userID:(nullable NSString *)userID;
- (void)removeDelegate:(id <HBTwitterAPIClientDelegate>)delegate forUsername:(nullable NSString *)username userID:(nullable NSString *)userID;

@end

NS_ASSUME_NONNULL_END
