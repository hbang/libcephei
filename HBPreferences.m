#define _HB_PREFERENCES_M
#import "HBPreferences.h"

static NSString *const HBPreferencesNotMobileException = @"HBPreferencesNotMobileException";
static NSString *const HBPreferencesDidChangeNotification = @"HBPreferencesDidChangeNotification";

static NSMutableDictionary *KnownIdentifiers;

@implementation HBPreferences {
	NSMutableDictionary *_preferences;
	NSMutableDictionary *_pointers;
}

+ (instancetype)preferencesForIdentifier:(NSString *)identifier {
	return [[[self alloc] initWithIdentifier:identifier] autorelease];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
	if (KnownIdentifiers[identifier]) {
		return [KnownIdentifiers[identifier] retain];
	}

	self = [self init];

	if (self) {
		_identifier = [identifier copy];
		_defaults = [[NSMutableDictionary alloc] init];
		_pointers = [[NSMutableDictionary alloc] init];

		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			KnownIdentifiers = [[NSMutableDictionary alloc] init];
		});

		KnownIdentifiers[_identifier] = self;
	}

	return self;
}

#pragma mark - Reloading

- (BOOL)synchronize {
	// TODO
	/*
	if (![NSUserName() isEqualToString:@"mobile"]) {
		[NSException raise:HBPreferencesNotMobileException format:@"Writing preferences as a non-mobile user is disallowed."];
	}

	BOOL success = NO;

	if (_isDirty) {
		_isDirty = NO;
		success = [_preferences writeToURL:self._path atomically:YES];

		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBPreferencesDidChangeNotification object:self]];
	}

	[self _reloadPreferences];

	return success && _preferences != nil;
	*/

	return YES;
}

- (void)_reloadPreferences {
	// TODO
	/*
	[_preferences release];
	_preferences = [[NSDictionary alloc] initWithContentsOfURL:self._path];

	for (NSString *key in _preferences.allKeys) {
		if ([_pointers.allKeys containsObject:key]) {
			void *pointer = _pointers[key];
			*pointer = _preferences[key];
		}
	}
	*/
}

#pragma mark - Getters

- (id)_objectForKey:(NSString *)key {
	return [(id)CFPreferencesCopyValue((CFStringRef)key, (CFStringRef)_identifier, CFSTR("mobile"), kCFPreferencesCurrentHost) autorelease];
}

- (id)objectForKey:(NSString *)key {
	return [self _objectForKey:key] ?: _defaults[key];
}

- (NSInteger)integerForKey:(NSString *)key {
	NSNumber *value = [self objectForKey:key];
	return [value isKindOfClass:NSNumber.class] ? value.integerValue : 0;
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

- (void)setObject:(id)value forKey:(NSString *)key {
	_preferences[key] = value;
	[self synchronize];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
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

#pragma mark - Register preferences

- (void)registerObject:(void *)object default:(id)defaultValue forKey:(NSString *)key {
	_defaults[key] = defaultValue;
	_pointers[key] = object;
}

- (void)registerInteger:(NSInteger *)object default:(NSInteger)defaultValue forKey:(NSString *)key {
	[self registerObject:object default:@(defaultValue) forKey:key];
}

- (void)registerFloat:(CGFloat *)object default:(CGFloat)defaultValue forKey:(NSString *)key {
	[self registerObject:object default:@(defaultValue) forKey:key];
}

- (void)registerDouble:(double *)object default:(double)defaultValue forKey:(NSString *)key {
	[self registerObject:object default:@(defaultValue) forKey:key];
}

- (void)registerBool:(BOOL *)object default:(BOOL)defaultValue forKey:(NSString *)key {
	[self registerObject:object default:@(defaultValue) forKey:key];
}

- (void)registerDefaults:(NSDictionary *)defaults {
	[_defaults addEntriesFromDictionary:defaults];
}

#pragma mark - Memory management

- (void)dealloc {
	[_identifier release];
	[_defaults release];
	[_pointers release];
	[super dealloc];
}

@end
