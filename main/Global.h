#import <UIKit/UIApplication.h>
#import <UIKit/UIApplication+Private.h>

// Are we in the system app? Before iOS 8, the only system app is SpringBoard. With the introduction
// of FrontBoard in iOS 8, other apps (e.g. PineBoard and Carousel) can be the system app.
// +[UIApplication registerAsSystemApp] will tell us if we’re in a system app, and the UIApplication
// subclass should also be the principal class of the bundle.
// Cephei avoids linking UIKit, so we need to be careful to not directly use UIKit symbols here.
#define IS_SYSTEM_APP ([[NSBundle mainBundle].principalClass isKindOfClass:NSClassFromString(@"UIApplication")] \
	&& [[NSBundle mainBundle].principalClass respondsToSelector:@selector(registerAsSystemApp)] \
	&& (BOOL)[[NSBundle mainBundle].principalClass registerAsSystemApp])
