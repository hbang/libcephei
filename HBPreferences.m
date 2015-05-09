#define _HB_PREFERENCES_M
#import "HBPreferences.h"
#import <version.h>

#define HAS_CFPREFSD (IS_IOS_OR_NEWER(iOS_8_0))

typedef NS_ENUM(NSUInteger, HBPreferencesType) {
	HBPreferencesTypeObjectiveC,
	HBPreferencesTypeInteger,
	HBPreferencesTypeFloat,
	HBPreferencesTypeDouble,
	HBPreferencesTypeBoolean
};

NSString *const HBPreferencesNotMobileException = @"HBPreferencesNotMobileException";
NSString *const HBPreferencesDidChangeNotification = @"HBPreferencesDidChangeNotification";

static NSMutableDictionary *KnownIdentifiers;

#pragma mark - Darwin notification callback

@interface HBPreferences ()

- (void)_didReceiveDarwinNotification;

@end

void HBPreferencesDarwinNotifyCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSString *identifier = ((NSString *)name).stringByDeletingLastPathComponent;
	HBPreferences *preferences = KnownIdentifiers[identifier];

	if (!preferences) {
		return;
	}

	[preferences _didReceiveDarwinNotification];
}

@implementation HBPreferences {
	NSMutableDictionary *_preferences;
	NSMutableDictionary *_pointers;

	NSMutableDictionary *_preferenceChangeBlocks;
	NSMutableArray *_preferenceChangeBlocksGlobal;
}

#pragma mark - Initialization

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

		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, HBPreferencesDarwinNotifyCallback, (CFStringRef)[_identifier stringByAppendingPathComponent:@"ReloadPrefs"], NULL, kNilOptions);
	}

	return self;
}

#pragma mark - Reloading

- (BOOL)synchronize {
	return CFPreferencesSynchronize((CFStringRef)_identifier, CFSTR("mobile"), kCFPreferencesCurrentHost);
}

- (void)_didReceiveDarwinNotification {
	if (!HAS_CFPREFSD) {
		[self synchronize];
	}

	[self _updateRegisteredObjects];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBPreferencesDidChangeNotification object:self]];

	if (_preferenceChangeBlocks && _preferenceChangeBlocks.allKeys.count > 0) {
		for (NSString *key in _preferenceChangeBlocks) {
			for (HBPreferencesChangeCallback callback in _preferenceChangeBlocks[key]) {
				callback(key, [self objectForKey:key]);
			}
		}
	}

	if (_preferenceChangeBlocksGlobal && _preferenceChangeBlocksGlobal.count > 0) {
		for (HBPreferencesChangeCallback callback in _preferenceChangeBlocksGlobal) {
			callback();
		}
	}
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
				id *pointer_ = pointer;
				*pointer_ = [self objectForKey:key];
				break;
			}

			case HBPreferencesTypeInteger:
			{
				NSInteger *pointer_ = pointer;
				*pointer_ = [self integerForKey:key];
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
	if (getuid() != 501) {
		[NSException raise:HBPreferencesNotMobileException format:@"Writing preferences as a non-mobile user is disallowed."];
	}

	_preferences[key] = value;

	CFPreferencesSetValue((CFStringRef)key, (CFPropertyListRef)value, (CFStringRef)_identifier, CFSTR("mobile"), kCFPreferencesCurrentHost);

	if (!HAS_CFPREFSD) {
		[self synchronize];
	}

	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBPreferencesDidChangeNotification object:self]];
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

- (void)_registerObject:(void *)object default:(id)defaultValue forKey:(NSString *)key type:(HBPreferencesType)type {
	_defaults[key] = defaultValue;
	_pointers[key] = @[ @(type), [NSValue valueWithPointer:object] ];

	[self _updateRegisteredObjects];
}

- (void)registerObject:(id *)object default:(id)defaultValue forKey:(NSString *)key {
	[self _registerObject:object default:defaultValue forKey:key type:HBPreferencesTypeObjectiveC];
}

- (void)registerInteger:(NSInteger *)object default:(NSInteger)defaultValue forKey:(NSString *)key {
	[self _registerObject:object default:@(defaultValue) forKey:key type:HBPreferencesTypeInteger];
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

- (void)registerDefaults:(NSDictionary *)defaults {
	[_defaults addEntriesFromDictionary:defaults];
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

	callback(key, [self objectForKey:key]);
}

#pragma mark - Memory management

- (void)dealloc {
	[_identifier release];
	[_defaults release];
	[_pointers release];
	[_preferenceChangeBlocks release];
	[_preferenceChangeBlocksGlobal release];

	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

@end
