@interface HBRespringController : NSObject

+ (void)respring;
+ (void)respringAndReturnTo:(nullable NSURL *)returnURL;

@end