#define ROCKETBOOTSTRAP_LOAD_DYNAMIC
#import <LightMessaging/LightMessaging.h>

typedef NS_ENUM(NSUInteger, HBPreferencesIPCMessageType) {
	HBPreferencesIPCMessageTypeSynchronize,
	HBPreferencesIPCMessageTypeGetAll,
	HBPreferencesIPCMessageTypeGet,
	HBPreferencesIPCMessageTypeSet
};

static LMConnection springboardService = {
	MACH_PORT_NULL,
	"cy:ws.hbang.common.preferences.springboardserver"
};
