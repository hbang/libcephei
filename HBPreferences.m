#import "HBPreferences-Private.h"
#import "HBPreferencesIPC.h"
#import <version.h>
#include <sandbox.h>
#include <dlfcn.h>

#define USE_CONTAINER_FUNCTIONS (IS_IOS_OR_NEWER(iOS_8_0) && getuid() != 0)

#define kCFPreferencesNoContainer CFSTR("kCFPreferencesNoContainer")

typedef CFPropertyListRef (*_CFPreferencesCopyValueWithContainerType)(CFStringRef key, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);
typedef void (*_CFPreferencesSetValueWithContainerType)(CFStringRef key, CFPropertyListRef value, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);
typedef Boolean (*_CFPreferencesSynchronizeWithContainerType)(CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);
typedef CFArrayRef (*_CFPreferencesCopyKeyListWithContainerType)(CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);
typedef CFDictionaryRef (*_CFPreferencesCopyMultipleWithContainerType)(CFArrayRef keysToFetch, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);

_CFPreferencesCopyValueWithContainerType _CFPreferencesCopyValueWithContainer;
_CFPreferencesSetValueWithContainerType _CFPreferencesSetValueWithContainer;
_CFPreferencesSynchronizeWithContainerType _CFPreferencesSynchronizeWithContainer;
_CFPreferencesCopyKeyListWithContainerType _CFPreferencesCopyKeyListWithContainer;
_CFPreferencesCopyMultipleWithContainerType _CFPreferencesCopyMultipleWithContainer;

NSString *const HBPreferencesNotMobileException = @"HBPreferencesNotMobileException";

#pragma mark - Class implementation

@implementation HBPreferences

- (instancetype)initWithIdentifier:(NSString *)identifier {
	// we may not have the appropriate sandbox rules to access the preferences from this process, so
	// find out whether we do or not. if we don’t, swap the instance of this class out for an instance
	// of the class that works around this by doing IPC with our springboard server
	if (IN_SPRINGBOARD || sandbox_check(getpid(), "user-preference-read", SANDBOX_FILTER_PREFERENCE_DOMAIN | SANDBOX_CHECK_NO_REPORT, identifier) == KERN_SUCCESS) {
		self = [super initWithIdentifier:identifier];
	} else {
		self = (HBPreferences *)[[HBPreferencesIPC alloc] initWithIdentifier:identifier];
	}

	return self;
}

#pragma mark - Initialization

+ (void)initialize {
	[super initialize];

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_CFPreferencesCopyValueWithContainer = (_CFPreferencesCopyValueWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesCopyValueWithContainer");
		_CFPreferencesSetValueWithContainer = (_CFPreferencesSetValueWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesSetValueWithContainer");
		_CFPreferencesSynchronizeWithContainer = (_CFPreferencesSynchronizeWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesSynchronizeWithContainer");
		_CFPreferencesCopyKeyListWithContainer = (_CFPreferencesCopyKeyListWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesCopyKeyListWithContainer");
		_CFPreferencesCopyMultipleWithContainer = (_CFPreferencesCopyMultipleWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesCopyMultipleWithContainer");
	});
}

#pragma mark - Reloading

- (BOOL)synchronize {
	if (USE_CONTAINER_FUNCTIONS) {
		return _CFPreferencesSynchronizeWithContainer((__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, kCFPreferencesNoContainer);
	} else {
		return CFPreferencesSynchronize((__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	}
}

#pragma mark - Dictionary representation

- (NSDictionary <NSString *, id> *)dictionaryRepresentation {
	CFDictionaryRef result;

	if (USE_CONTAINER_FUNCTIONS) {
		CFArrayRef allKeys = _CFPreferencesCopyKeyListWithContainer((__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, kCFPreferencesNoContainer);

		if (!allKeys) {
			return @{};
		}

		result = _CFPreferencesCopyMultipleWithContainer(allKeys, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, kCFPreferencesNoContainer);
		CFBridgingRelease(allKeys);
	} else {
		CFArrayRef allKeys = CFPreferencesCopyKeyList((__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);

		if (!allKeys) {
			return @{};
		}

		result = CFPreferencesCopyMultiple(allKeys, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
		CFBridgingRelease(allKeys);
	}

	return (__bridge NSDictionary *)result;
}

#pragma mark - Getters

- (id)_objectForKey:(NSString *)key {
	CFTypeRef value;

	if (USE_CONTAINER_FUNCTIONS) {
		value = _CFPreferencesCopyValueWithContainer((__bridge CFStringRef)key, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, kCFPreferencesNoContainer);
		CFBridgingRelease(value);
	} else {
		value = CFPreferencesCopyValue((__bridge CFStringRef)key, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
		CFBridgingRelease(value);
	}

	id objcValue = (__bridge id)value;

	[self _storeValue:objcValue forKey:key];

	return objcValue;
}

#pragma mark - Setters

- (void)_setObject:(id)value forKey:(NSString *)key {
	if (getuid() != 501) {
		[NSException raise:HBPreferencesNotMobileException format:@"Writing preferences as a non-mobile user is disallowed."];
	}

	if (USE_CONTAINER_FUNCTIONS) {
		_CFPreferencesSetValueWithContainer((__bridge CFStringRef)key, (__bridge CFPropertyListRef)value, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, kCFPreferencesNoContainer);
	} else {
		CFPreferencesSetValue((__bridge CFStringRef)key, (__bridge CFPropertyListRef)value, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	}

	[self _storeValue:value forKey:key];
}

@end
