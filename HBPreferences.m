#import "HBPreferences-Private.h"
#import "HBPreferencesIPC.h"
#import <version.h>

// Ensure private symbols don’t get included if we’re in embedded mode. Any empty code paths will be
// optimised out by the compiler.
#if !CEPHEI_EMBEDDED
#import <sandbox.h>
static BOOL isSystemApp;
#endif

#pragma mark - Class implementation

@implementation HBPreferences

#pragma mark - Initialization

#if !CEPHEI_EMBEDDED
+ (void)initialize {
	[super initialize];

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		isSystemApp = IS_SYSTEM_APP;
	});
}
#endif

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
	} else {
		self = (HBPreferences *)[[HBPreferencesIPC alloc] initWithIdentifier:identifier];
	}
#endif

	return self;
}

#pragma mark - Reloading

- (BOOL)synchronize {
	return CFPreferencesSynchronize((__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
}

#pragma mark - Dictionary representation

- (NSDictionary <NSString *, id> *)dictionaryRepresentation {
	CFArrayRef allKeys = CFPreferencesCopyKeyList((__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	if (!allKeys) {
		return @{};
	}
	CFDictionaryRef result = CFPreferencesCopyMultiple(allKeys, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	CFRelease(allKeys);
	return (__bridge_transfer NSDictionary *)result;
}

#pragma mark - Getters

- (id)_objectForKey:(NSString *)key {
	id value = CFBridgingRelease(CFPreferencesCopyValue((__bridge CFStringRef)key, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost));
	[self _storeValue:value forKey:key];
	return value;
}

#pragma mark - Setters

- (void)_setObject:(id)value forKey:(NSString *)key {
	CFPreferencesSetValue((__bridge CFStringRef)key, (__bridge CFPropertyListRef)value, (__bridge CFStringRef)self.identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	[self _storeValue:value forKey:key];
}

@end
