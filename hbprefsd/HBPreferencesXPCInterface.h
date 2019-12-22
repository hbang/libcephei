@import Foundation;

@protocol HBPreferencesXPCInterface

- (void)synchronizeForIdentifier:(NSString *)identifier;
- (void)dictionaryRepresentationForIdentifier:(NSString *)identifier withReply:(void (^)(NSDictionary *))reply;
- (void)objectForKey:(NSString *)key forIdentifier:(NSString *)identifier withReply:(void (^)(id <NSSecureCoding>))reply;
- (void)setObject:(id <NSSecureCoding>)value forKey:(NSString *)key forIdentifier:(NSString *)identifier;

@end
