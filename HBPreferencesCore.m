#import "HBPreferencesCore.h"
#import "HBPreferencesCore+Conveniences.h"
#import "HBPreferences.h"
#include <notify.h>

typedef NS_ENUM(NSUInteger, HBPreferencesType) {
	HBPreferencesTypeObjectiveC,
	HBPreferencesTypeInteger,
	HBPreferencesTypeUnsignedInteger,
	HBPreferencesTypeFloat,
	HBPreferencesTypeDouble,
	HBPreferencesTypeBoolean
};

NSString *const HBPreferencesDidChangeNotification = @"HBPreferencesDidChangeNotification";

NSMutableDictionary <NSString *, HBPreferencesCore *> *KnownIdentifiers;

@implementation HBPreferencesCore {
	NSMutableDictionary <NSString *, id> *_lastSeenValues;
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
	if (KnownIdentifiers[identifier]) {
		return KnownIdentifiers[identifier];
	}

	self = [self init];

	if (self) {
		_identifier = [identifier copy];
		_defaults = [[NSMutableDictionary alloc] init];
		_pointers = [[NSMutableDictionary alloc] init];
		_lastSeenValues = [[NSMutableDictionary alloc] init];

		KnownIdentifiers[_identifier] = self;

		__block NSString *identifier = _identifier;

		int notifyToken;
		notify_register_dispatch([_identifier stringByAppendingPathComponent:@"ReloadPrefs"].UTF8String, &notifyToken, dispatch_get_main_queue(), ^(int token) {
			HBLogDebug(@"received change notification - reloading preferences");

			// if we know this identifier
			if (KnownIdentifiers[identifier]) {
				// reload just that one
				[(HBPreferencesCore *)KnownIdentifiers[identifier] _didReceiveDarwinNotification];
			} else {
				HBLogWarn(@"Identifier %@ is not known. Reloading all known HBPreferences instances. (This functionality will be removed a future release.)", identifier);

				// just in case... reload all of them
				for (NSString *key in KnownIdentifiers) {
					[(HBPreferencesCore *)KnownIdentifiers[key] _didReceiveDarwinNotification];
				}
			}
		});
	}

	return self;
}

#pragma mark - Reloading

- (void)synchronize {}

- (void)_preferencesChanged {
	[self synchronize];

	NSDictionary <NSString *, id> *lastSeenValues = [_lastSeenValues copy];

	[self _updateRegisteredObjects];

	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBPreferencesDidChangeNotification object:self]];

	if (_preferenceChangeBlocks && _preferenceChangeBlocks.allKeys.count > 0) {
		for (NSString *key in _preferenceChangeBlocks) {
			id lastValue = lastSeenValues[key];
			id newValue = [self _objectForKey:key];

			if (newValue != lastValue || (newValue == nil && [lastValue isKindOfClass:NSNull.class]) || ![newValue isEqual:lastValue]) {
				for (HBPreferencesChangeCallback callback in _preferenceChangeBlocks[key]) {
					callback(key, [self objectForKey:key]);
				}
			}
		}
	}

	if (_preferenceChangeBlocksGlobal && _preferenceChangeBlocksGlobal.count > 0) {
		for (HBPreferencesChangeCallback callback in _preferenceChangeBlocksGlobal) {
			callback();
		}
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

- (void)_storeValue:(id)value forKey:(NSString *)key {
	_lastSeenValues[key] = value ?: [[NSNull alloc] init];
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
	return [self _objectForKey:key] ?: _defaults[key];
}

#pragma mark - Setters

- (void)_setObject:(id)value forKey:(NSString *)key {}

- (void)setObject:(id)value forKey:(NSString *)key {
	[self _setObject:value forKey:key];
	[self _preferencesChanged];
}

#pragma mark - Register preferences

- (void)_registerObject:(void *)object default:(id)defaultValue forKey:(NSString *)key type:(HBPreferencesType)type {
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
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_preferenceChangeBlocksGlobal = [[NSMutableArray alloc] init];
	});

	[_preferenceChangeBlocksGlobal addObject:[callback copy]];

	callback();
}

- (void)registerPreferenceChangeBlock:(HBPreferencesValueChangeCallback)callback forKey:(NSString *)key {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_preferenceChangeBlocks = [[NSMutableDictionary alloc] init];
	});

	if (!_preferenceChangeBlocks[key]) {
		_preferenceChangeBlocks[key] = [[NSMutableArray alloc] init];
	}

	[(NSMutableArray *)_preferenceChangeBlocks[key] addObject:[callback copy]];
	[self _objectForKey:key];

	callback(key, [self objectForKey:key]);
}

#pragma mark - Memory management

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
