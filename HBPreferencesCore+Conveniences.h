#import "HBPreferencesCore.h"

@interface HBPreferencesCore (Conveniences)

- (id)objectForKeyedSubscript:(NSString *)key;

- (NSInteger)integerForKey:(NSString *)key;
- (NSUInteger)unsignedIntegerForKey:(NSString *)key;
- (CGFloat)floatForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;

- (id)objectForKey:(NSString *)key default:(id)defaultValue;
- (NSInteger)integerForKey:(NSString *)key default:(NSInteger)defaultValue;
- (NSUInteger)unsignedIntegerForKey:(NSString *)key default:(NSUInteger)defaultValue;
- (CGFloat)floatForKey:(NSString *)key default:(CGFloat)defaultValue;
- (double)doubleForKey:(NSString *)key default:(double)defaultValue;
- (BOOL)boolForKey:(NSString *)key default:(BOOL)defaultValue;

- (void)setObject:(id)value forKeyedSubscript:(NSString *)key;

- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
- (void)setUnsignedInteger:(NSUInteger)value forKey:(NSString *)key;
- (void)setFloat:(CGFloat)value forKey:(NSString *)key;
- (void)setDouble:(double)value forKey:(NSString *)key;
- (void)setBool:(BOOL)value forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;
- (void)removeAllObjects;

- (void)registerDefaults:(NSDictionary <NSString *, id> *)defaults;

@end
