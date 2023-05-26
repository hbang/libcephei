#import "HBPreferencesCore.h"
#import "HBPreferencesCore+Conveniences.h"
#import "HBPreferences.h"
#import <HBLog.h>
#import <notify.h>

typedef NS_ENUM(NSUInteger, HBPreferencesType) {
	HBPreferencesTypeObjectiveC,
	HBPreferencesTypeInteger,
	HBPreferencesTypeUnsignedInteger,
	HBPreferencesTypeFloat,
	HBPreferencesTypeDouble,
	HBPreferencesTypeBoolean
};

NSString *const HBPreferencesDidChangeNotification = @"HBPreferencesDidChangeNotification";

static NSMutableDictionary <NSString *, HBPreferencesCore *> *KnownIdentifiers;

@implementation HBPreferencesCore {
	NSMapTable *_lastSeenValues;
	NSMutableDictionary <NSString *, NSArray <id> *> *_pointers;

	NSMutableDictionary <NSString *, NSArray <HBPreferencesChangeCallback> *> *_preferenceChangeBlocks;
	NSMutableArray <HBPreferencesValueChangeCallback> *_preferenceChangeBlocksGlobal;
}

#pragma mark - Initialization

+ (void)initialize {
	[super initialize];

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		KnownIdentifiers = [[NSMutableDictionary alloc] init];
	});
}

+ (instancetype)preferencesForIdentifier:(NSString *)identifier {
	return [[self alloc] initWithIdentifier:identifier];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
	NSParameterAssert(identifier);

	if (KnownIdentifiers[identifier]) {
		return KnownIdentifiers[identifier];
	}

	self = [self init];

	if (self) {
		_identifier = [identifier copy];
		_defaults = [[NSMutableDictionary alloc] init];
		_pointers = [[NSMutableDictionary alloc] init];
		_lastSeenValues = NSCreateMapTable(NSObjectMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);

		KnownIdentifiers[_identifier] = self;

		__block NSString *identifier = _identifier;

		int notifyToken;
		notify_register_dispatch([_identifier stringByAppendingPathComponent:@"ReloadPrefs"].UTF8String, &notifyToken, dispatch_get_main_queue(), ^(int token) {
			HBLogDebug(@"Received change notification for %@ - reloading preferences", identifier);
			[(HBPreferencesCore *)KnownIdentifiers[identifier] _didReceiveDarwinNotification];
		});
	}

	return self;
}

#pragma mark - Reloading

- (void)_preferencesChanged {
	// We need to copy lastSeenValues now, so we have the state of last seen values before we start
	// accessing these values and therefore changing the hashes in _lastSeenValues.
	NSMapTable *lastSeenValues = NSCopyMapTableWithZone(_lastSeenValues, NULL);

	[self _updateRegisteredObjects];

	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBPreferencesDidChangeNotification object:self]];

	// Handle KVO notifications and callback blocks.
	NSArray <NSString *> *keys = NSAllMapTableKeys(lastSeenValues);
	for (NSString *key in keys) {
		NSUInteger lastValue = (NSUInteger)NSMapGet(lastSeenValues, (__bridge CFStringRef)key);
		NSUInteger newValue = [self _calculateHashForValue:[self _objectForKey:key]];
		if (newValue != lastValue) {
			[self willChangeValueForKey:key];
			for (HBPreferencesValueChangeCallback callback in _preferenceChangeBlocks[key]) {
				callback(key, [self objectForKey:key]);
			}
			[self didChangeValueForKey:key];
		}
	}

	// Finally, handle any general global callbacks.
	for (HBPreferencesChangeCallback callback in _preferenceChangeBlocksGlobal) {
		callback();
	}
}

- (void)_didReceiveDarwinNotification {
	[self _preferencesChanged];
}

- (void)_updateRegisteredObjects {
	for (NSString *key in _pointers.allKeys) {
		HBPreferencesType type = ((NSNumber *)_pointers[key][0]).unsignedIntegerValue;
		void *pointer = ((NSValue *)_pointers[key][1]).pointerValue;

		if (!pointer) {
			continue;
		}

		switch (type) {
			case HBPreferencesTypeObjectiveC:
			{
				__strong id *pointer_ = (__strong id *)pointer;
				*pointer_ = [self objectForKey:key];
				break;
			}

			case HBPreferencesTypeInteger:
			{
				NSInteger *pointer_ = pointer;
				*pointer_ = [self integerForKey:key];
				break;
			}

			case HBPreferencesTypeUnsignedInteger:
			{
				NSInteger *pointer_ = pointer;
				*pointer_ = [self unsignedIntegerForKey:key];
				break;
			}

			case HBPreferencesTypeFloat:
			{
				CGFloat *pointer_ = pointer;
				*pointer_ = [self floatForKey:key];
				break;
			}

			case HBPreferencesTypeDouble:
			{
				double *pointer_ = pointer;
				*pointer_ = [self doubleForKey:key];
				break;
			}

			case HBPreferencesTypeBoolean:
			{
				BOOL *pointer_ = pointer;
				*pointer_ = [self boolForKey:key];
				break;
			}
		}
	}
}

- (NSUInteger)_calculateHashForValue:(NSObject *)value {
	// NSArray and NSDictionary’s hash methods are pretty useless. Do our best to try and calculate
	// our own. This hash can overflow of course, but it’s not a big deal because the value should
	// still be consistent.
	static NSUInteger magicNumber = 7;
	if ([value isKindOfClass:NSArray.class]) {
		NSArray *array = (NSArray *)value;
		NSUInteger hash = 0;
		for (id item in array) {
			hash = magicNumber * hash + [self _calculateHashForValue:item];
		}
		return hash;
	} else if ([value isKindOfClass:NSDictionary.class]) {
		NSDictionary *dictionary = (NSDictionary *)value;
		NSUInteger hash = 0;
		NSArray *sortedKeys = [dictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
		for (id key in sortedKeys) {
			hash = magicNumber * hash + [self _calculateHashForValue:key];
			hash = magicNumber * hash + [self _calculateHashForValue:dictionary[key]];
		}
		return hash;
	}

	return (value ?: [NSNull null]).hash;
}

- (void)_storeValue:(id)value forKey:(NSString *)key {
	NSMapInsert(_lastSeenValues, (__bridge CFStringRef)key, (void *)[self _calculateHashForValue:value]);
}

#pragma mark - Dictionary representation

- (NSDictionary <NSString *, id> *)dictionaryRepresentation {
	return nil;
}

#pragma mark - Getters

- (id)_objectForKey:(NSString *)key {
	return nil;
}

- (id)objectForKey:(NSString *)key {
	NSParameterAssert(key);
	return [self _objectForKey:key] ?: _defaults[key];
}

#pragma mark - Setters

- (void)_setObject:(id)value forKey:(NSString *)key {}

- (void)setObject:(id)value forKey:(NSString *)key {
	NSParameterAssert(key);

	[self _setObject:value forKey:key];
	[self _preferencesChanged];
}

#pragma mark - Register preferences

- (void)_registerObject:(void *)object default:(id)defaultValue forKey:(NSString *)key type:(HBPreferencesType)type {
	NSParameterAssert(object);
	NSParameterAssert(key);

	if (defaultValue) {
		_defaults[key] = defaultValue;
	}

	_pointers[key] = @[ @(type), [NSValue valueWithPointer:object] ];

	[self _updateRegisteredObjects];
}

- (void)registerObject:(id __strong *)object default:(id)defaultValue forKey:(NSString *)key {
	[self _registerObject:object default:defaultValue forKey:key type:HBPreferencesTypeObjectiveC];
}

- (void)registerInteger:(NSInteger *)object default:(NSInteger)defaultValue forKey:(NSString *)key {
	[self _registerObject:object default:@(defaultValue) forKey:key type:HBPreferencesTypeInteger];
}

- (void)registerUnsignedInteger:(NSUInteger *)object default:(NSUInteger)defaultValue forKey:(NSString *)key {
	[self _registerObject:object default:@(defaultValue) forKey:key type:HBPreferencesTypeUnsignedInteger];
}

- (void)registerFloat:(CGFloat *)object default:(CGFloat)defaultValue forKey:(NSString *)key {
	[self _registerObject:object default:@(defaultValue) forKey:key type:HBPreferencesTypeFloat];
}

- (void)registerDouble:(double *)object default:(double)defaultValue forKey:(NSString *)key {
	[self _registerObject:object default:@(defaultValue) forKey:key type:HBPreferencesTypeDouble];
}

- (void)registerBool:(BOOL *)object default:(BOOL)defaultValue forKey:(NSString *)key {
	[self _registerObject:object default:@(defaultValue) forKey:key type:HBPreferencesTypeBoolean];
}

#pragma mark - Register block

- (void)registerPreferenceChangeBlock:(HBPreferencesChangeCallback)callback {
	if (!_preferenceChangeBlocksGlobal) {
		_preferenceChangeBlocksGlobal = [[NSMutableArray alloc] init];
	}

	NSParameterAssert(callback);

	[_preferenceChangeBlocksGlobal addObject:[callback copy]];
	callback();
}

- (void)registerPreferenceChangeBlockForKey:(NSString *)key block:(HBPreferencesValueChangeCallback)callback {
	if (!_preferenceChangeBlocks) {
		_preferenceChangeBlocks = [[NSMutableDictionary alloc] init];
	}

	NSParameterAssert(callback);
	NSParameterAssert(key);

	if (!_preferenceChangeBlocks[key]) {
		_preferenceChangeBlocks[key] = [[NSMutableArray alloc] init];
	}

	[(NSMutableArray *)_preferenceChangeBlocks[key] addObject:[callback copy]];
	[self _objectForKey:key];

	callback(key, [self objectForKey:key]);
}

@end
