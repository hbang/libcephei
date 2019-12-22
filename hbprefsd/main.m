#import "HBPreferencesXPCServiceDelegate.h"
#import "../HBPreferencesCommon.h"
#import <version.h>

#define ROCKETBOOTSTRAP_LOAD_DYNAMIC 1
#import <rocketbootstrap/rocketbootstrap.h>

@protocol HBPreferencesGoAwaySillyError

- (instancetype)initWithMachServiceName:(NSString *)name;

@end

@interface NSXPCListener () <HBPreferencesGoAwaySillyError>

@end

int main(int argc, char *argv[]) {
	if (!IS_IOS_OR_NEWER(iOS_8_0)) {
		return 0;
	}

	HBPreferencesXPCServiceDelegate *delegate = [[HBPreferencesXPCServiceDelegate alloc] init];
	NSXPCListener *listener = (NSXPCListener *)[(id <HBPreferencesGoAwaySillyError>)[NSXPCListener alloc] initWithMachServiceName:kHBPreferencesXPCMachServiceName];
	listener.delegate = delegate;
	[listener resume];
	rocketbootstrap_unlock(kHBPreferencesXPCMachServiceName.UTF8String);

	dispatch_main();

	// We should never get past here. If the system needs to free resources, we’ll get SIGKILLed.
	return 1;
}
