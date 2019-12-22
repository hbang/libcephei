#import "HBPreferencesIPC.h"
#import "HBPreferencesCommon.h"
#import "hbprefsd/HBPreferencesXPCInterface.h"
#import <HBLog.h>

@protocol HBPreferencesGoAwaySillyError

- (instancetype)initWithMachServiceName:(NSString *)name options:(NSXPCConnectionOptions)options;

@end

@interface NSXPCConnection () <HBPreferencesGoAwaySillyError>

@end

@implementation HBPreferencesIPC {
	NSXPCConnection *_xpcConnection;
	id <HBPreferencesXPCInterface> _xpcProxy;
}

#if CEPHEI_EMBEDDED
- (instancetype)initWithIdentifier:(NSString *)identifier {
	[NSException raise:NSInternalInconsistencyException format:@"HBPreferencesIPC is not available in embedded mode."];
	return nil;
}
#else
- (instancetype)initWithIdentifier:(NSString *)identifier {
	NSParameterAssert(identifier);

	// block apple preferences from being read/written via IPC for security. these are also blocked at
	// the server side. see HBPreferences.h for an explanation
	if ([identifier hasPrefix:@"com.apple."] || [identifier isEqualToString:@"UITextInputContextIdentifiers"]) {
		HBLogWarn(@"An attempt to access potentially sensitive Apple preferences was blocked. See https://hbang.github.io/libcephei/Classes/HBPreferences.html for more information.");
		return nil;
	}

	self = [super initWithIdentifier:identifier];

	if (self) {
		_xpcConnection = (NSXPCConnection *)[(id <HBPreferencesGoAwaySillyError>)[NSXPCConnection alloc] initWithMachServiceName:kHBPreferencesXPCMachServiceName options:NSXPCConnectionPrivileged];
		_xpcConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HBPreferencesXPCInterface)];
		[_xpcConnection resume];
		_xpcProxy = _xpcConnection.remoteObjectProxy;
	}

	return self;
}

#pragma mark - Reloading

- (BOOL)synchronize {
	[_xpcProxy synchronizeForIdentifier:self.identifier];
	return YES;
}

#pragma mark - Dictionary representation

- (NSDictionary <NSString *, id> *)dictionaryRepresentation {
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	__block NSDictionary *result = nil;
	[_xpcProxy dictionaryRepresentationForIdentifier:self.identifier withReply:^(NSDictionary *result2) {
		result = result2;
		dispatch_semaphore_signal(semaphore);
	}];
	dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 50));
	return result;
}

#pragma mark - Getters

- (id)_objectForKey:(NSString *)key {
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	__block id result = nil;
	[_xpcProxy objectForKey:key forIdentifier:self.identifier withReply:^(id result2) {
		result = result2;
		dispatch_semaphore_signal(semaphore);
	}];
	dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 50));
	return result;
}

#pragma mark - Setters

- (void)_setObject:(id)value forKey:(NSString *)key {
	NSParameterAssert(value);
	NSParameterAssert(key);

	[_xpcProxy setObject:value forKey:key forIdentifier:self.identifier];
	[self _storeValue:value forKey:key];
}
#endif

@end
