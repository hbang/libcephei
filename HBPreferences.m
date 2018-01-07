#import "HBPreferences-Private.h"
#import "HBPreferencesIPC.h"
#import <version.h>
#include <sandbox.h>
#include <dlfcn.h>

// ensure private symbols don’t get included if we’re in embedded mode. any empty code paths will be
// optimised out by the compiler
#if CEPHEI_EMBEDDED
#define USE_CONTAINER_FUNCTIONS NO
#else
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
#endif

NSString *const HBPreferencesNotMobileException = @"HBPreferencesNotMobileException";

#pragma mark - Class implementation

@implementation HBPreferences {
	CFStringRef _container;
}

#pragma mark - Initialization

+ (void)initialize {
	[super initialize];

#if !CEPHEI_EMBEDDED
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_CFPreferencesCopyValueWithContainer = (_CFPreferencesCopyValueWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesCopyValueWithContainer");
		_CFPreferencesSetValueWithContainer = (_CFPreferencesSetValueWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesSetValueWithContainer");
		_CFPreferencesSynchronizeWithContainer = (_CFPreferencesSynchronizeWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesSynchronizeWithContainer");
		_CFPreferencesCopyKeyListWithContainer = (_CFPreferencesCopyKeyListWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesCopyKeyListWithContainer");
		_CFPreferencesCopyMultipleWithContainer = (_CFPreferencesCopyMultipleWithContainerType)dlsym(RTLD_DEFAULT, "_CFPreferencesCopyMultipleWithContainer");
	});
#endif
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
	NSParameterAssert(identifier);

#if CEPHEI_EMBEDDED
	self = [super initWithIdentifier:identifier];

	// always use a nil container when embedded. there’s no point trying to support reading/writing
	// preferences we can’t access without the IPC relay available
	_container = nil;
#else
	// we may not have the appropriate sandbox rules to access the preferences from this process, so
	// find out whether we do or not. if we don’t, swap the instance of this class out for an instance
	// of the class that works around this by doing IPC with our springboard server
	if (IN_SPRINGBOARD || sandbox_check(getpid(), "user-preference-read", SANDBOX_FILTER_PREFERENCE_DOMAIN | SANDBOX_CHECK_NO_REPORT, identifier) == KERN_SUCCESS) {
		self = [super initWithIdentifier:identifier];

		// a nil container indicates to use the current container. kCFPreferencesNoContainer forces the
		// user’s home directory to be used. we assume that if the identifier starts with the app bundle
		// id, and it’s not an apple app, it probably wants its own preferences inside its container
		// TODO: is there a better way to guess this? should we not guess at all except for the exact
		// main bundle id?
		if (![[[NSBundle mainBundle].bundleIdentifier stringByAppendingString:@"."] hasPrefix:[identifier stringByAppendingString:@"."]]) {
			_container = kCFPreferencesNoContainer;
		}
	} else {
		self = (HBPreferences *)[[HBPreferencesIPC alloc] initWithIdentifier:identifier];
	}
#endif

	return self;
}

#pragma mark - Reloading

- (BOOL)synchronize {
	if (USE_CONTAINER_FUNCTIONS) {
#if !CEPHEI_EMBEDDED
		return _CFPreferencesSynchronizeWithContainer((__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, _container);
#endif
	} else {
		return CFPreferencesSynchronize((__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	}
}

#pragma mark - Dictionary representation

- (NSDictionary <NSString *, id> *)dictionaryRepresentation {
	CFDictionaryRef result;

	if (USE_CONTAINER_FUNCTIONS) {
#if !CEPHEI_EMBEDDED
		CFArrayRef allKeys = _CFPreferencesCopyKeyListWithContainer((__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, _container);

		if (!allKeys) {
			return @{};
		}

		result = _CFPreferencesCopyMultipleWithContainer(allKeys, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, _container);
		CFBridgingRelease(allKeys);
		CFBridgingRelease(result);
#endif
	} else {
		CFArrayRef allKeys = CFPreferencesCopyKeyList((__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);

		if (!allKeys) {
			return @{};
		}

		result = CFPreferencesCopyMultiple(allKeys, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
		CFBridgingRelease(allKeys);
		CFBridgingRelease(result);
	}

	return (__bridge NSDictionary *)result;
}

#pragma mark - Getters

- (id)_objectForKey:(NSString *)key {
	CFTypeRef value;

	if (USE_CONTAINER_FUNCTIONS) {
#if !CEPHEI_EMBEDDED
		value = _CFPreferencesCopyValueWithContainer((__bridge CFStringRef)key, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, _container);
		CFBridgingRelease(value);
#endif
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
#if !CEPHEI_EMBEDDED
		_CFPreferencesSetValueWithContainer((__bridge CFStringRef)key, (__bridge CFPropertyListRef)value, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, _container);
#endif
	} else {
		CFPreferencesSetValue((__bridge CFStringRef)key, (__bridge CFPropertyListRef)value, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	}

	[self _storeValue:value forKey:key];
}

@end
