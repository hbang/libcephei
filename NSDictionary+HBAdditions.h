NS_ASSUME_NONNULL_BEGIN

/**
 * NSDictionary (HBAdditions) is a class category in `Cephei` that provides some convenience methods.
 */
@interface NSDictionary (HBAdditions)

/**
 * Constructs and returns an NSString object that is the result of joining the dictionary keys and
 * values into an HTTP query string.
 *
 * 
 *
 * @returns An NSString containing an HTTP query string.
 */
- (NSString *)hb_queryString;

@end

NS_ASSUME_NONNULL_END
