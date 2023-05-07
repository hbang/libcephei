#import "HBPreferences-Private.h"
#import "HBPreferencesIPC.h"
#import <version.h>

// Ensure private symbols don’t get included if we’re in embedded mode. Any empty code paths will be
// optimised out by the compiler.
#if !CEPHEI_EMBEDDED
#import <dlfcn.h>
#import <sandbox.h>

#define kCFPreferencesNoContainer CFSTR("kCFPreferencesNoContainer")

typedef CFPropertyListRef (*_CFPreferencesCopyValueWithContainerType)(CFStringRef key, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);
typedef void (*_CFPreferencesSetValueWithContainerType)(CFStringRef key, CFPropertyListRef value, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);
typedef Boolean (*_CFPreferencesSynchronizeWithContainerType)(CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);
typedef CFArrayRef (*_CFPreferencesCopyKeyListWithContainerType)(CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);
typedef CFDictionaryRef (*_CFPreferencesCopyMultipleWithContainerType)(CFArrayRef keysToFetch, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName, CFStringRef containerPath);

static _CFPreferencesCopyValueWithContainerType _CFPreferencesCopyValueWithContainer;
static _CFPreferencesSetValueWithContainerType _CFPreferencesSetValueWithContainer;
static _CFPreferencesSynchronizeWithContainerType _CFPreferencesSynchronizeWithContainer;
static _CFPreferencesCopyKeyListWithContainerType _CFPreferencesCopyKeyListWithContainer;
static _CFPreferencesCopyMultipleWithContainerType _CFPreferencesCopyMultipleWithContainer;

static BOOL isSystemApp;
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

		isSystemApp = IS_SYSTEM_APP;
	});
#endif
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
	NSParameterAssert(identifier);

#if CEPHEI_EMBEDDED || TARGET_OS_SIMULATOR
	self = [super initWithIdentifier:identifier];

	// Always use a nil container when embedded. There’s no point trying to support reading/writing
	// preferences we can’t access without the IPC relay available.
	_container = nil;
#else
	// We may not have the appropriate sandbox rules to access the preferences from this process, so
	// find out whether we do or not. If we don’t, swap the instance of this class out for an instance
	// of the class that works around this by doing IPC with our preferences server.
	if (isSystemApp || sandbox_check(getpid(), "user-preference-read", SANDBOX_FILTER_PREFERENCE_DOMAIN | SANDBOX_CHECK_NO_REPORT, identifier) == KERN_SUCCESS) {
		self = [super initWithIdentifier:identifier];

		// iOS 8 and newer don’t fall back to the user’s home directory if the identifier isn’t found
		// within the container’s directory. We also assume no container is in use if the process is
		// running as root.
		// A nil container indicates to use the current container. kCFPreferencesNoContainer forces the
		// user’s home directory to be used. We assume that if the identifier starts with the app bundle
		// id, it probably wants its own preferences inside its container.
		// TODO: Is there a better way to guess this? Should we not guess at all except for the exact
		// main bundle id?
		if (getuid() != 0 && ![[[NSBundle mainBundle].bundleIdentifier stringByAppendingString:@"."] hasPrefix:[identifier stringByAppendingString:@"."]] && ![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"ws.hbang.Terminal"]) {
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
	if (_container) {
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

	if (_container) {
#if !CEPHEI_EMBEDDED
		CFArrayRef allKeys = _CFPreferencesCopyKeyListWithContainer((__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, _container);

		if (!allKeys) {
			return @{};
		}

		result = _CFPreferencesCopyMultipleWithContainer(allKeys, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, _container);
		CFRelease(allKeys);
#endif
	} else {
		CFArrayRef allKeys = CFPreferencesCopyKeyList((__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);

		if (!allKeys) {
			return @{};
		}

		result = CFPreferencesCopyMultiple(allKeys, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
		CFRelease(allKeys);
	}

	return (__bridge_transfer NSDictionary *)result;
}

#pragma mark - Getters

- (id)_objectForKey:(NSString *)key {
	CFTypeRef value;

	if (_container) {
#if !CEPHEI_EMBEDDED
		value = _CFPreferencesCopyValueWithContainer((__bridge CFStringRef)key, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, _container);
#endif
	} else {
		value = CFPreferencesCopyValue((__bridge CFStringRef)key, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	}

	id objcValue = CFBridgingRelease(value);

	[self _storeValue:objcValue forKey:key];

	return objcValue;
}

#pragma mark - Setters

- (void)_setObject:(id)value forKey:(NSString *)key {
	if (_container) {
#if !CEPHEI_EMBEDDED
		_CFPreferencesSetValueWithContainer((__bridge CFStringRef)key, (__bridge CFPropertyListRef)value, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost, _container);
#endif
	} else {
		CFPreferencesSetValue((__bridge CFStringRef)key, (__bridge CFPropertyListRef)value, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	}

	[self _storeValue:value forKey:key];
}

@end
