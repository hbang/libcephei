NS_ASSUME_NONNULL_BEGIN

/**
 * The `HBRespringController` class in `Cephei` provides conveniences for
 * restarting SpringBoard. It also ensures battery usage statistics are not lost
 * when performing the restart.
 *
 * In order for `HBRespringController` to work on iOS versions before 8.0, at
 * least one tweak must link against `Cephei.framework` in order for its
 * respring action listener to be registered.
 */
@interface HBRespringController : NSObject

/**
 * Restart SpringBoard.
 *
 * On iOS 8.0 and newer, fades out and then returns to the home screen (system
 * remains unlocked). On older iOS versions, a standard restart occurs.
 */
+ (void)respring;

/**
 * Restart SpringBoard and immediately launch a URL.
 *
 * Requires iOS 8.0 or newer. On older iOS versions, a standard restart occurs.
 *
 * @param returnURL The URL to launch after restarting.
 */
+ (void)respringAndReturnTo:(nullable NSURL *)returnURL;

@end

NS_ASSUME_NONNULL_END
