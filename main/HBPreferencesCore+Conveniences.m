#import "HBPreferencesCore+Conveniences.h"

@implementation HBPreferencesCore (Conveniences)

#pragma mark - KVO

- (id)valueForUndefinedKey:(NSString *)key {
	// Called by valueForKey: when the key doesn’t exist. Usually this throws an exception. We use
	// this opportunity to try and grab a matching value from preferences instead. Using KVO on this
	// class will therefore never abort on undefined keys.
	return [self objectForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	// As above, if the key doesnt exist, we treat it as intending to write to the preferences.
	[self setObject:value forKey:key];
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
	// We need to first get the initial value for this key so our KVO notifications will work. This
	// will read the key from the preferences, so we have its hash value in _lastSeenValues.
	[self valueForKeyPath:keyPath];

	[super addObserver:observer forKeyPath:keyPath options:options context:context];
}

#pragma mark - Getters

- (NSInteger)integerForKey:(NSString *)key {
	NSNumber *value = [self objectForKey:key];
	return [value respondsToSelector:@selector(integerValue)] ? value.integerValue : 0;
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)key {
	NSNumber *value = [self objectForKey:key];
	return [value respondsToSelector:@selector(unsignedIntegerValue)] ? value.unsignedIntegerValue : 0;
}

- (CGFloat)floatForKey:(NSString *)key {
	NSNumber *value = [self objectForKey:key];
	return [value respondsToSelector:@selector(doubleValue)] ? value.doubleValue : 0;
}

- (double)doubleForKey:(NSString *)key {
	NSNumber *value = [self objectForKey:key];
	return [value respondsToSelector:@selector(doubleValue)] ? value.doubleValue : 0;
}

- (BOOL)boolForKey:(NSString *)key {
	NSNumber *value = [self objectForKey:key];
	return [value respondsToSelector:@selector(boolValue)] ? value.boolValue : NO;
}

- (id)objectForKeyedSubscript:(NSString *)key {
	return [self objectForKey:key];
}

- (id)objectForKey:(NSString *)key default:(id)defaultValue {
	return [self _objectForKey:key] ?: defaultValue;
}

- (NSInteger)integerForKey:(NSString *)key default:(NSInteger)defaultValue {
	NSNumber *value = [self objectForKey:key default:@(defaultValue)];
	return [value respondsToSelector:@selector(integerValue)] ? value.integerValue : 0;
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)key default:(NSUInteger)defaultValue {
	NSNumber *value = [self objectForKey:key default:@(defaultValue)];
	return [value respondsToSelector:@selector(unsignedIntegerValue)] ? value.unsignedIntegerValue : 0;
}

- (CGFloat)floatForKey:(NSString *)key default:(CGFloat)defaultValue {
	NSNumber *value = [self objectForKey:key default:@(defaultValue)];
	return [value respondsToSelector:@selector(doubleValue)] ? value.doubleValue : 0;
}

- (double)doubleForKey:(NSString *)key default:(double)defaultValue {
	NSNumber *value = [self objectForKey:key default:@(defaultValue)];
	return [value respondsToSelector:@selector(doubleValue)] ? value.doubleValue : 0;
}

- (BOOL)boolForKey:(NSString *)key default:(BOOL)defaultValue {
	NSNumber *value = [self objectForKey:key default:@(defaultValue)];
	return [value respondsToSelector:@selector(boolValue)] ? value.boolValue : NO;
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
