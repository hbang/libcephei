#import "HBPreferencesIPC.h"
#import "HBPreferencesCommon.h"

@implementation HBPreferencesIPC

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
	[self _sendMessageType:HBPreferencesIPCMessageTypeSet key:key value:value];
	[self _storeValue:value forKey:key];
}

@end
