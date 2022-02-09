#import "HBPreferencesIPC.h"
#import "HBPreferencesCommon.h"
#import <HBLog.h>
#import <version.h>

static LMConnection preferencesService;

@implementation HBPreferencesIPC

+ (void)initialize {
	[super initialize];

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// Determine which service name to use. libhooker implements the same sandbox workaround via
		// a two-letter prefixed service name as Substrate does, but because of reasons that effectively
		// amount to hand-waving, it intentionally chooses to not be compatible with the de-facto cy:
		// prefix. So we need to just guess the service name to use here. The prefix has no meaning when
		// RocketBootstrap is providing the sandbox workaround (pre-iOS 11).
		if (access("/usr/lib/libhooker.dylib", F_OK) == 0) {
			preferencesService = preferencesServiceLibhooker;
		} else {
			preferencesService = preferencesServiceSubstrate;
		}
	});
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
	NSParameterAssert(identifier);

	// Block Apple preferences from being read/written via IPC for security. These are also blocked at
	// the server side. See HBPreferences.h for an explanation.
	if ([identifier hasPrefix:@"com.apple."] || [identifier isEqualToString:@"UITextInputContextIdentifiers"]) {
		HBLogWarn(@"An attempt to access potentially sensitive Apple preferences was blocked. See https://hbang.github.io/libcephei/Classes/HBPreferences.html for more information.");
		return nil;
	}

	self = [super initWithIdentifier:identifier];
	return self;
}

- (id)_sendMessageType:(HBPreferencesIPCMessageType)type key:(nullable NSString *)key value:(nullable NSString *)value {
#if CEPHEI_EMBEDDED
	[NSException raise:NSInternalInconsistencyException format:@"HBPreferencesIPC is not available in embedded mode."];
	return nil;
#else
	// Construct our message dictionary with the basics
	NSMutableDictionary <NSString *, id> *data = [@{
		@"Type": @(type),
		@"Identifier": self.identifier
	} mutableCopy];

	// If we’ve been provided a key, add that in
	if (key) {
		data[@"Key"] = key;
	}

	// If we’ve been provided a value, add that too
	if (value) {
		data[@"Value"] = value;
	}

	// Send the message, and return the response.
	LMResponseBuffer buffer;
	kern_return_t result = LMConnectionSendTwoWayPropertyList(&preferencesService, 0, data, &buffer);
	if (result != KERN_SUCCESS) {
		HBLogError(@"Could not contact preferences IPC server! (Error %i)", result);
		return nil;
	}
	return LMResponseConsumePropertyList(&buffer);
#endif
}

#pragma mark - Reloading

- (BOOL)synchronize {
	if (IS_IOS_OR_NEWER(iOS_12_0)) {
		// Don’t bother doing IPC at all, since we know synchronize does nothing on iOS 12+.
		return YES;
	}

	NSNumber *result = [self _sendMessageType:HBPreferencesIPCMessageTypeSynchronize key:nil value:nil];
	return result.boolValue;
}

#pragma mark - Dictionary representation

- (NSDictionary <NSString *, id> *)dictionaryRepresentation {
	return [self _sendMessageType:HBPreferencesIPCMessageTypeGetAll key:nil value:nil];
}

#pragma mark - Getters

- (id)_objectForKey:(NSString *)key {
	id value = [self _sendMessageType:HBPreferencesIPCMessageTypeGet key:key value:nil];
	[self _storeValue:value forKey:key];

	return value;
}

#pragma mark - Setters

- (void)_setObject:(id)value forKey:(NSString *)key {
	NSParameterAssert(value);
	NSParameterAssert(key);

	[self _sendMessageType:HBPreferencesIPCMessageTypeSet key:key value:value];
	[self _storeValue:value forKey:key];
}

@end
