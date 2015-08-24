#define _HB_PREFERENCES_M
#import "HBPreferences.h"
#import <version.h>
#include <dlfcn.h>

#define HAS_CFPREFSD (IS_IOS_OR_NEWER(iOS_8_0))

typedef CFPropertyListRef (*_CFPreferencesCopyValueWithContainerType)(CFStringRef key, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);
typedef void (*_CFPreferencesSetValueWithContainerType)(CFStringRef key, CFPropertyListRef value, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);
typedef Boolean (*_CFPreferencesSynchronizeWithContainerType)(CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);

_CFPreferencesCopyValueWithContainerType _CFPreferencesCopyValueWithContainer;
_CFPreferencesSetValueWithContainerType _CFPreferencesSetValueWithContainer;
_CFPreferencesSynchronizeWithContainerType _CFPreferencesSynchronizeWithContainer;

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
	HBLogDebug(@"received change notification - reloading preferences");

	for (NSString *key in KnownIdentifiers) {
		[(HBPreferences *)KnownIdentifiers[key] _didReceiveDarwinNotification];
	}
}

#pragma mark - Class implementation

@implementation HBPreferences {
	NSMutableDictionary *_lastSeenValues;
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
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			KnownIdentifiers = [[NSMutableDictionary alloc] init];

			_CFPreferencesCopyValueWithContainer = (_CFPreferencesCopyValueWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesCopyValueWithContainer");
			_CFPreferencesSetValueWithContainer = (_CFPreferencesSetValueWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesCopyValueWithContainer");
			_CFPreferencesSynchronizeWithContainer = (_CFPreferencesSynchronizeWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesCopyValueWithContainer");

			// CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)HBPreferencesDarwinNotifyCallback, CFSTR("com.apple.CFPreferences._domainsChangedExternally"), NULL, kNilOptions);
		});

		_identifier = [identifier copy];
		_defaults = [[NSMutableDictionary alloc] init];
		_pointers = [[NSMutableDictionary alloc] init];
		_lastSeenValues = [[NSMutableDictionary alloc] init];

		KnownIdentifiers[_identifier] = self;

		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)HBPreferencesDarwinNotifyCallback, (CFStringRef)[_identifier stringByAppendingPathComponent:@"ReloadPrefs"], NULL, kNilOptions);
	}

	return self;
}

#pragma mark - Reloading

- (BOOL)synchronize {
	if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
		return CFPreferencesSynchronize((CFStringRef)_identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	} else {
		return _CFPreferencesSynchronizeWithContainer((CFStringRef)_identifier, CFSTR("mobile"), kCFPreferencesAnyHost, CFSTR("/var/mobile"));
	}
}

- (void)_didReceiveDarwinNotification {
	if (!HAS_CFPREFSD) {
		[self synchronize];
	}

	[self _updateRegisteredObjects];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBPreferencesDidChangeNotification object:self]];

	if (_preferenceChangeBlocks && _preferenceChangeBlocks.allKeys.count > 0) {
		for (NSString *key in _preferenceChangeBlocks) {
			id newValue = [self _objectForKey:key];

			if (newValue != _lastSeenValues[key] || (newValue == nil && [_lastSeenValues[key] isKindOfClass:NSNull.class]) || ![newValue isEqual:_lastSeenValues[key]]) {
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

- (NSDictionary *)dictionaryRepresentation {
	// TODO: needs to support being in a container
	CFArrayRef allKeys = CFPreferencesCopyKeyList((CFStringRef)_identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	NSDictionary *result = [(NSDictionary *)CFPreferencesCopyMultiple(allKeys, (CFStringRef)_identifier, CFSTR("mobile"), kCFPreferencesAnyHost) autorelease];
	CFRelease(allKeys);

	return result;
}

- (id)_objectForKey:(NSString *)key {
	id value = [(id)_CFPreferencesCopyValueWithContainer((CFStringRef)key, (CFStringRef)_identifier, CFSTR("mobile"), kCFPreferencesAnyHost, CFSTR("/var/mobile")) autorelease];

	_lastSeenValues[key] = value ?: [[NSNull alloc] init];

	return value;
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

	if (value) {
		[_lastSeenValues removeObjectForKey:value];
	} else {
		_lastSeenValues[key] = value;
	}

	if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
		CFPreferencesSetValue((CFStringRef)key, (CFPropertyListRef)value, (CFStringRef)_identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	} else {
		_CFPreferencesSetValueWithContainer((CFStringRef)key, (CFPropertyListRef)value, (CFStringRef)_identifier, CFSTR("mobile"), kCFPreferencesAnyHost, CFSTR("/var/mobile"));
	}

	[self synchronize];

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

#pragma mark - Remove

- (void)removeObjectForKey:(NSString *)key {
	[self setObject:nil forKey:key];
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
	[_identifier release];
	[_defaults release];
	[_pointers release];
	[_preferenceChangeBlocks release];
	[_preferenceChangeBlocksGlobal release];
	[_lastSeenValues release];

	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

@end
