#import "HBPreferencesIPC.h"
#import "HBPreferencesCommon.h"
#import <HBLog.h>

@implementation HBPreferencesIPC

- (instancetype)initWithIdentifier:(NSString *)identifier {
	NSParameterAssert(identifier);

	// block apple preferences from being read/written via IPC for security. these are also blocked at
	// the server side. see HBPreferences.h for an explanation
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
	// construct our message dictionary with the basics
	NSMutableDictionary <NSString *, id> *data = [@{
		@"Type": @(type),
		@"Identifier": self.identifier
	} mutableCopy];

	// if we’ve been provided a key, add that in
	if (key) {
		data[@"Key"] = key;
	}

	// if we’ve been provided a value, add that too
	if (value) {
		data[@"Value"] = value;
	}

	// send the message, and hopefully have it placed in the response buffer
	LMResponseBuffer buffer;
	kern_return_t result = LMConnectionSendTwoWayPropertyList(&springboardService, 0, data, &buffer);

	// if it failed, log and return nil
	if (result != KERN_SUCCESS) {
		HBLogError(@"Could not contact preferences IPC server! (Error %i)",result);
		return nil;
	}

	// return what we got back
	return LMResponseConsumePropertyList(&buffer);
#endif
}

#pragma mark - Reloading

- (BOOL)synchronize {
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
