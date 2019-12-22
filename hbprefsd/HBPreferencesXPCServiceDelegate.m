#import "HBPreferencesXPCServiceDelegate.h"
#import "HBPreferencesXPCService.h"
#import "HBPreferencesXPCInterface.h"

@implementation HBPreferencesXPCServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
	newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HBPreferencesXPCInterface)];
	newConnection.exportedObject = [[HBPreferencesXPCService alloc] init];
	[newConnection resume];
	return YES;
}

@end
