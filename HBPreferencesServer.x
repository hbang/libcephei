#import "HBPreferences.h"
#import "HBPreferencesCommon.h"

#pragma mark - IPC

static void HandleReceivedMessage(CFMachPortRef port, void *bytes, CFIndex size, void *info) {
	LMMessage *request = bytes;

	// check that we aren’t being given a corrupt message
	if ((size_t)size < sizeof(LMMessage)) {
		HBLogError(@"received a bad message? size = %li", size);

		// send a blank reply, free the buffer, and return
		LMSendReply(request->head.msgh_remote_port, NULL, 0);
		LMResponseBufferFree(bytes);

		return;
	}

	// get the raw data sent
	const void *rawData = LMMessageGetData(request);
	size_t length = LMMessageGetDataLength(request);

	// translate to NSData, then NSDictionary
	CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)rawData, length, kCFAllocatorNull);
	NSDictionary <NSString *, id> *userInfo = LMPropertyListForData((__bridge NSData *)data);
	CFRelease(data);

	// decode the type parameter to an enum value
	HBPreferencesIPCMessageType type = (HBPreferencesIPCMessageType)((NSNumber *)userInfo[@"Type"]).unsignedIntegerValue;

	// instantiate an HBPreferences instance for this identifier. this will be looked up from
	// HBPreferences’ known identifiers cache, so this almost always won’t hurt performance
	HBPreferences *preferences = [HBPreferences preferencesForIdentifier:userInfo[@"Identifier"]];

	id result;

	// do the appropriate thing for each message type
	switch (type) {
		case HBPreferencesIPCMessageTypeSynchronize:
			result = @([preferences synchronize]);
			break;

		case HBPreferencesIPCMessageTypeGetAll:
			result = preferences.dictionaryRepresentation;
			break;

		case HBPreferencesIPCMessageTypeGet:
			result = preferences[userInfo[@"Key"]];
			break;

		case HBPreferencesIPCMessageTypeSet:
			result = @{};
			[preferences setObject:userInfo[@"Value"] forKey:userInfo[@"Key"]];
			break;
	}

	// send the data back, and free the buffer
	LMSendPropertyListReply(request->head.msgh_remote_port, result);
	LMResponseBufferFree(bytes);
}

#pragma mark - Constructor

%ctor {
	// don’t do anything unless we’re in springboard
	if (!IN_SPRINGBOARD) {
		return;
	}

	// start the service
	kern_return_t result = LMStartService(springboardService.serverName, CFRunLoopGetCurrent(), HandleReceivedMessage);

	// if it failed, log it
	if (result != KERN_SUCCESS) {
		HBLogError(@"Failed to start preferences IPC service! (Error %i)", result);
	}
}
