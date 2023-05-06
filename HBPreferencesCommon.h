#import <LightMessaging/LightMessaging.h>

typedef NS_ENUM(NSUInteger, HBPreferencesIPCMessageType) {
	HBPreferencesIPCMessageTypeSynchronize,
	HBPreferencesIPCMessageTypeGetAll,
	HBPreferencesIPCMessageTypeGet,
	HBPreferencesIPCMessageTypeSet
};

static LMConnection preferencesServiceSubstrate = {
	MACH_PORT_NULL,
	"cy:ws.hbang.common.preferencesservice"
};

static LMConnection preferencesServiceLibhooker = {
	MACH_PORT_NULL,
	"lh:ws.hbang.common.preferencesservice"
};
