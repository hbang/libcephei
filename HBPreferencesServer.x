#import "HBPreferences.h"
#import "HBPreferencesCommon.h"
#import <HBLog.h>
#include <dlfcn.h>

#if !CEPHEI_EMBEDDED && !TARGET_OS_SIMULATOR

#pragma mark - IPC

static void HandleReceivedMessage(CFMachPortRef port, void *bytes, CFIndex size, void *info) {
	LMMessage *request = bytes;

	// Check that we aren’t being given a corrupt message
	if ((size_t)size < sizeof(LMMessage)) {
		// Send a blank reply, free the buffer, and return
		HBLogError(@"Received a bad message? size = %li", size);
		LMSendReply(request->head.msgh_remote_port, NULL, 0);
		LMResponseBufferFree(bytes);
		return;
	}

	NSDictionary <NSString *, id> *userInfo = LMResponseConsumePropertyList((LMResponseBuffer *)request);

	// Deserialize the parameters
	NSString *identifier = userInfo[@"Identifier"];
	HBPreferencesIPCMessageType type = (HBPreferencesIPCMessageType)((NSNumber *)userInfo[@"Type"]).unsignedIntegerValue;
	id result;

	// We block Apple preferences from being read/written via IPC for security. This check is also on
	// the client side; this code path will never be reached unless something sends a message over the
	// port directly. See HBPreferences docs for an explanation.
	if ([identifier hasPrefix:@"com.apple."] || [identifier isEqualToString:@"UITextInputContextIdentifiers"]) {
		// Send empty dictionary back, free the buffer, and return
		LMSendPropertyListReply(request->head.msgh_remote_port, @{});
		LMResponseBufferFree(bytes);
		return;
	}

	// Instantiate an HBPreferences instance for this identifier. This will be looked up from
	// HBPreferences’ known identifiers cache, so this almost always won’t hurt performance
	HBPreferences *preferences = [HBPreferences preferencesForIdentifier:identifier];

	// Do the appropriate thing for each message type
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

	// Send the data back, and free the buffer
	LMSendPropertyListReply(request->head.msgh_remote_port, result);
	LMResponseBufferFree(bytes);
}

#pragma mark - Constructor

%ctor {
	// Don’t do anything unless we’re in SpringBoard
	if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		return;
	}

	// Determine which service name to use. libhooker implements the same sandbox workaround via
	// a two-letter prefixed service name as Substrate does, but because of reasons that effectively
	// amount to hand-waving, it intentionally chooses to not be compatible with the de-facto cy:
	// prefix. So we need to just guess the service name to use here. The prefix has no meaning when
	// RocketBootstrap is providing the sandbox workaround (pre-iOS 11).
	name_t serviceName;
	if (access("/usr/lib/libhooker.dylib", F_OK) == 0) {
		serviceName = preferencesServiceLibhooker.serverName;
	} else {
		serviceName = preferencesServiceSubstrate.serverName;
	}

	// Start the service
	kern_return_t result = LMStartService(serviceName, CFRunLoopGetCurrent(), HandleReceivedMessage);
	if (result != KERN_SUCCESS) {
		HBLogError(@"Failed to start preferences IPC service! (Error %i)", result);
	}
}

#endif
