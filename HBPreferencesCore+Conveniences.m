#import "HBPreferencesCore+Conveniences.h"

@implementation HBPreferencesCore (Conveniences)

#pragma mark - Getters

- (NSInteger)integerForKey:(NSString *)key {
	NSNumber *value = [self objectForKey:key];
	return [value isKindOfClass:NSNumber.class] ? value.integerValue : 0;
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)key {
	NSNumber *value = [self objectForKey:key];
	return [value isKindOfClass:NSNumber.class] ? value.unsignedIntegerValue : 0;
}

- (CGFloat)floatForKey:(NSString *)key {
	NSNumber *value = [self objectForKey:key];
	return [value isKindOfClass:NSNumber.class] ? value.floatValue : 0;
}

- (double)doubleForKey:(NSString *)key {
	NSNumber *value = [self objectForKey:key];
	return [value isKindOfClass:NSNumber.class] ? value.doubleValue : 0;
}

- (BOOL)boolForKey:(NSString *)key {
	NSNumber *value = [self objectForKey:key];
	return [value isKindOfClass:NSNumber.class] ? value.boolValue : NO;
}

- (id)objectForKeyedSubscript:(NSString *)key {
	return [self objectForKey:key];
}

- (id)objectForKey:(NSString *)key default:(id)defaultValue {
	return [self _objectForKey:key] ?: defaultValue;
}

- (NSInteger)integerForKey:(NSString *)key default:(NSInteger)defaultValue {
	NSNumber *value = [self objectForKey:key default:@(defaultValue)];
	return [value isKindOfClass:NSNumber.class] ? value.integerValue : 0;
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)key default:(NSUInteger)defaultValue {
	NSNumber *value = [self objectForKey:key default:@(defaultValue)];
	return [value isKindOfClass:NSNumber.class] ? value.unsignedIntegerValue : 0;
}

- (CGFloat)floatForKey:(NSString *)key default:(CGFloat)defaultValue {
	NSNumber *value = [self objectForKey:key default:@(defaultValue)];
	return [value isKindOfClass:NSNumber.class] ? value.floatValue : 0;
}

- (double)doubleForKey:(NSString *)key default:(double)defaultValue {
	NSNumber *value = [self objectForKey:key default:@(defaultValue)];
	return [value isKindOfClass:NSNumber.class] ? value.doubleValue : 0;
}

- (BOOL)boolForKey:(NSString *)key default:(BOOL)defaultValue {
	NSNumber *value = [self objectForKey:key default:@(defaultValue)];
	return [value isKindOfClass:NSNumber.class] ? value.boolValue : NO;
}

#pragma mark - Setters

- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
	[self setObject:@(value) forKey:key];
}

- (void)setUnsignedInteger:(NSUInteger)value forKey:(NSString *)key {
	[self setObject:@(value) forKey:key];
}

- (void)setFloat:(CGFloat)value forKey:(NSString *)key {
	[self setObject:@(value) forKey:key];
}

- (void)setDouble:(double)value forKey:(NSString *)key {
	[self setObject:@(value) forKey:key];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
	[self setObject:@(value) forKey:key];
}

- (void)setObject:(id)value forKeyedSubscript:(NSString *)key {
	[self setObject:value forKey:key];
}

#pragma mark - Remove

- (void)removeObjectForKey:(NSString *)key {
	[self setObject:nil forKey:key];
}

- (void)removeAllObjects {
	for (NSString *key in self.dictionaryRepresentation.allKeys) {
		[self _setObject:nil forKey:key];
	}

	[self _preferencesChanged];
}

#pragma mark - Register defaults

- (void)registerDefaults:(NSDictionary <NSString *, id> *)defaults {
	NSParameterAssert(defaults);

	[self.defaults addEntriesFromDictionary:defaults];
}

@end
