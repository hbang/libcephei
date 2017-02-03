#import <LightMessaging/LightMessaging.h>

typedef NS_ENUM(NSUInteger, HBPreferencesIPCMessageType) {
	HBPreferencesIPCMessageTypeSynchronize,
	HBPreferencesIPCMessageTypeGetAll,
	HBPreferencesIPCMessageTypeGet,
	HBPreferencesIPCMessageTypeSet
};

static LMConnection springboardService = {
	MACH_PORT_NULL,
	"ws.hbang.common.preferences.springboardserver"
};
