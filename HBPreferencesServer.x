#import "HBPreferences.h"
#import "HBPreferencesCommon.h"
#include <dlfcn.h>

#if !CEPHEI_EMBEDDED && !TARGET_OS_SIMULATOR

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

	// deserialize the parameters
	NSString *identifier = userInfo[@"Identifier"];
	HBPreferencesIPCMessageType type = (HBPreferencesIPCMessageType)((NSNumber *)userInfo[@"Type"]).unsignedIntegerValue;
	id result;

	// we block apple preferences from being read/written via IPC for security. this check is also on
	// the client side; this code path will never be reached unless something sends a message over the
	// port directly. see HBPreferences.h for an explanation
	if ([identifier hasPrefix:@"com.apple."] || [identifier isEqualToString:@"UITextInputContextIdentifiers"]) {
		// send empty dictionary back, free the buffer, and return
		LMSendPropertyListReply(request->head.msgh_remote_port, @{});
		LMResponseBufferFree(bytes);
		return;
	}

	// instantiate an HBPreferences instance for this identifier. this will be looked up from
	// HBPreferences’ known identifiers cache, so this almost always won’t hurt performance
	HBPreferences *preferences = [HBPreferences preferencesForIdentifier:identifier];

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

	if (!dlopen("/usr/lib/librocketbootstrap.dylib", RTLD_LAZY)) {
		// welp?
		return;
	}

	// start the service
	kern_return_t result = LMStartService(springboardService.serverName, CFRunLoopGetCurrent(), HandleReceivedMessage);

	// if it failed, log it
	if (result != KERN_SUCCESS) {
		HBLogError(@"Failed to start preferences IPC service! (Error %i)", result);
	}
}

#endif
