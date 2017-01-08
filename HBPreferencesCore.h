NS_ASSUME_NONNULL_BEGIN

@interface HBPreferencesCore : NSObject

@property (nonatomic, retain, readonly) NSString *identifier;

@property (nonatomic, copy, readonly) NSMutableDictionary <NSString *, id> *defaults;

- (nullable id)_objectForKey:(NSString *)key;
- (nullable id)objectForKey:(NSString *)key;

- (void)setObject:(nullable id)value forKey:(NSString *)key;

- (void)_storeValue:(nullable id)value forKey:(NSString *)key;

- (void)_preferencesChanged;

@end

NS_ASSUME_NONNULL_END
