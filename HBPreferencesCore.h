NS_ASSUME_NONNULL_BEGIN

@interface HBPreferencesCore : NSObject

@property (nonatomic, retain, readonly) NSString *identifier;

@property (nonatomic, copy, readonly) NSMutableDictionary <NSString *, id> *defaults;

- (instancetype)initWithIdentifier:(NSString *)identifier;

- (NSDictionary <NSString *, id> *)dictionaryRepresentation;

- (nullable id)_objectForKey:(NSString *)key;
- (nullable id)objectForKey:(NSString *)key;

- (void)_setObject:(nullable id)value forKey:(NSString *)key;
- (void)setObject:(nullable id)value forKey:(NSString *)key;

- (void)_storeValue:(nullable id)value forKey:(NSString *)key;

- (void)_preferencesChanged;

@end

NS_ASSUME_NONNULL_END
